defmodule Mix.Tasks.StripeSchemasFromOpenApi do
  use Mix.Task

  @supported_schemas [
    "customer",
    "charge",
    "checkout.session",
    "payment_intent"
  ]

  def run(_) do
    openapi = download_stripe_openapi_json()

    IO.inspect(Map.keys(openapi["components"]["schemas"]), label: "schemas", limit: :infinity)

    openapi["components"]["schemas"]
    |> Enum.filter(fn
      {name, _schema} when name in @supported_schemas -> true
      _ -> false
    end)
    # |> tap(fn x -> IO.inspect(x, label: "x") end)
    |> Enum.each(fn {name, schema} ->
      fields =
        schema["properties"]
        |> Enum.filter(fn {field_name, _field_schema} -> field_name != "id" end)
        |> Enum.map(fn {field_name, field_schema} ->
          {field_name, ecto_type_for(openapi, field_name, field_schema)}
        end)
        |> Enum.into(%{})

      today_str = Date.utc_today() |> Date.to_iso8601()

      fields_code =
        Enum.map_join(fields, "\n", fn {field_name, field_type} ->
          field_name = String.to_atom(field_name)
          " field(#{inspect(field_name)}, #{inspect(field_type)}) "
        end)

      columns_code =
        Enum.map_join(fields, "\n", fn {field_name, field_type} ->
          field_name = String.to_atom(field_name)
          "add(#{inspect(field_name)}, #{inspect(field_type)})"
        end)

      clean_name = String.replace(name, ".", "_")
      api_route = "/v1/" <> String.replace(name, ".", "/") <> "s"
      module_name = Macro.camelize(clean_name)

      module_code =
        """
        defmodule VendorSync.Stripe.Schemas.#{module_name} do
          @moduledoc \"""
          Stripe #{name} schema.

          Generated from Stripe OpenAPI spec on #{today_str}
          \"""

          use Ecto.Schema
          use Ecto.Migration

          @primary_key {:id, :binary_id, autogenerate: false}
          schema "stripe_#{clean_name}" do
            #{fields_code}
          end

          def up_migration do
            create table(:stripe_#{clean_name}, primary_key: false) do
              add(:id, :binary_id, primary_key: true)
              #{columns_code}
            end
          end

          def down_migration do
            drop(table(:stripe_#{clean_name}))
          end

          def api_route, do: "#{api_route}"
          def object_type, do: "#{name}"
        end
        """
        |> Code.format_string!()

      IO.inspect(module_name, label: "module_name")
      IO.inspect(Macro.underscore(module_name), label: "underscore")

      dest_path =
        "#{__DIR__}/../../../lib/stripe/schemas/#{Macro.underscore(module_name)}.ex"
        |> Path.expand()

      IO.puts("Writing to #{dest_path}")
      File.write(dest_path, module_code)
    end)
  end

  defp ecto_type_for(openapi, field_name, field_schema) do
    case field_schema do
      %{"type" => "string"} -> :string
      %{"type" => "integer"} -> :integer
      %{"type" => "boolean"} -> :boolean
      %{"type" => "object"} -> :map
      %{"type" => "array"} -> {:array, ecto_type_for(openapi, field_name, field_schema["items"])}
      %{"type" => "date-time"} -> :utc_datetime
      %{"type" => "number"} -> :float
      %{"type" => "null"} -> :string
      %{"anyOf" => [%{"type" => "string"} | _]} -> :string
      %{"anyOf" => _subtypes} -> :map
      %{"$ref" => _ref} -> :map
      nil -> raise "Unknown type found in #{field_name}: #{inspect(field_schema)}"
      type -> raise "Unknown type: #{inspect(type)}"
    end
  end

  @stripe_openapi_url "https://raw.githubusercontent.com/stripe/openapi/master/openapi/spec3.json"
  def download_stripe_openapi_json do
    dest_path = Path.expand("#{__DIR__}/../../../priv/openapi/stripe_openapi.json")
    IO.inspect(dest_path, label: "dest_path")

    if File.exists?(dest_path) do
      IO.puts("stripe_openapi.json already exists")
    else
      Req.get(@stripe_openapi_url, into: File.stream!(dest_path))
    end

    Jason.decode!(File.read!(dest_path))
  end
end
