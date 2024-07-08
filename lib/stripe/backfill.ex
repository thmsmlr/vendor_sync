defmodule VendorSync.Stripe.Job do
  @moduledoc false
  defstruct [:endpoint, :cursor]
end

defmodule VendorSync.Stripe.Backfill.Checkpoint do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Query

  alias VendorSync.Utilities

  schema "stripe__checkpoint" do
    field(:good_upto_event_id, :string)
    field(:events_processed, :integer, default: 0)
    timestamps()
  end

  @doc """
  Fetches the checkpoint for the backfilling process
  """
  def fetch_latest_checkpoint_event_id do
    case Utilities.repo().one(from(c in __MODULE__, order_by: [desc: c.inserted_at], limit: 1)) do
      nil -> nil
      checkpoint -> checkpoint.good_upto_event_id
    end
  end

  @doc """
  Inserts a new checkpoint for the backfilling process
  """
  def insert_new_backfill_checkpoint(event_id) when event_id != nil do
    Utilities.repo().insert(%__MODULE__{good_upto_event_id: event_id})
  end

  @doc """
  Updates the latest checkpoint to the given event_id and sets events_processed to true.

  to be used by the events poller
  """
  def update_latest_checkpoint(event_id, num_processed) when event_id != nil do
    latest_checkpoint_query =
      from(c in __MODULE__,
        order_by: [desc: c.inserted_at],
        limit: 1,
        select: c.id
      )

    update_query =
      from(c in __MODULE__,
        where: c.id in subquery(latest_checkpoint_query)
      )

    Utilities.repo().update_all(
      update_query,
      set: [
        good_upto_event_id: event_id,
        updated_at: DateTime.utc_now()
      ],
      inc: [events_processed: num_processed]
    )
  end
end

defmodule VendorSync.Stripe.Backfill do
  @moduledoc false

  alias VendorSync.Stripe.Job
  alias VendorSync.Stripe.Schemas
  alias VendorSync.Stripe.Backfill.Checkpoint
  alias VendorSync.RateLimiter
  alias VendorSync.Utilities

  def run() do
    latest_event_id = fetch_latest_event_id()
    {:ok, rate_limiter} = RateLimiter.start_link(messages: 50, interval: :timer.seconds(1))

    initial_jobs =
      for schema <- Schemas.all_schemas() do
        %Job{endpoint: schema.api_route, cursor: nil}
      end

    handle_job_rate_limited = fn job ->
      RateLimiter.enter(rate_limiter, fn -> handle_job(job) end)
    end

    Utilities.crawl(initial_jobs, handle_job_rate_limited, max_concurrency: 50)
    |> Stream.run()

    GenServer.stop(rate_limiter)
    Checkpoint.insert_new_backfill_checkpoint(latest_event_id)
  end

  defp handle_job(job) do
    start_time = System.monotonic_time()

    result =
      with {:ok, response} <- call_api(job),
           {:ok, objects} <- parse_data(job, response),
           :ok <- upsert_objects(objects),
           next_jobs <- next_jobs_from_response(job, response) do
        {nil, next_jobs}
      end

    :telemetry.execute(
      [:vendor_sync, :stripe, :request],
      %{duration: System.monotonic_time() - start_time},
      %{endpoint: job.endpoint}
    )

    result
  end

  defp call_api(job) do
    url = "https://api.stripe.com/#{job.endpoint}"
    params = %{"limit" => 100}
    params = if job.cursor, do: Map.put(params, "starting_after", job.cursor), else: params

    case Req.get(url, params: params, headers: %{"Authorization" => "Bearer #{secret_key()}"}) do
      {:ok, %Req.Response{status: status} = response} when status in 200..299 ->
        {:ok, response}

      {:ok, response} ->
        {:error, response}
    end
  end

  defp parse_data(job, response) do
    objects =
      response.body["data"]
      |> Enum.map(fn object ->
        case cast_object(job.endpoint, object) do
          %Ecto.Changeset{valid?: true} = changeset ->
            Ecto.Changeset.apply_changes(changeset)
        end
      end)

    {:ok, objects}
  end

  defp cast_object(endpoint, object) do
    schema = Schemas.all_schemas() |> Enum.find(&(&1.api_route == endpoint))
    schema.__struct__ |> Utilities.cast_all(object)
  end

  defp upsert_objects([]), do: :ok

  defp upsert_objects(objects) do
    schema = objects |> List.first() |> Map.get(:__struct__)
    data = objects |> Enum.map(&Map.take(&1, schema.__schema__(:fields)))
    num_objects = length(data)

    case Utilities.repo().insert_all(schema, data, on_conflict: :replace_all) do
      {^num_objects, _} ->
        :telemetry.execute(
          [:vendor_sync, :stripe, :upsert],
          %{count: num_objects},
          %{}
        )

        :ok
    end
  end

  defp next_jobs_from_response(job, response) do
    if get_in(response.body, ["has_more"]) do
      last_object = get_in(response.body, ["data"]) |> List.last()
      [%Job{job | cursor: last_object["id"]}]
    else
      []
    end
  end

  defp fetch_latest_event_id do
    res =
      Req.get(
        "https://api.stripe.com/v1/events",
        headers: %{"Authorization" => "Bearer #{secret_key()}"}
      )

    case res do
      {:ok, %Req.Response{status: status} = response} when status in 200..299 ->
        response.body["data"] |> List.first() |> Map.get("id")

      {:ok, response} ->
        {:error, response}
    end
  end

  defp secret_key do
    Application.get_env(:vendor_sync, :stripe, []) |> Keyword.get(:secret_key)
  end
end
