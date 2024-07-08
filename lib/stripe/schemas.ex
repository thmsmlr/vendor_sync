defmodule VendorSync.Stripe.Schemas do
  @moduledoc false

  @schemas_path "lib/stripe/schemas"

  def all_schemas do
    Path.expand("#{__DIR__}/../../#{@schemas_path}")
    |> File.ls!()
    |> Enum.map(fn file ->
      file_name = String.replace(file, ".ex", "")
      capitalized_name = Macro.camelize(file_name)
      module_name = Module.concat(VendorSync.Stripe.Schemas, capitalized_name)
      Code.ensure_loaded(module_name)
      module_name
    end)
  end
end
