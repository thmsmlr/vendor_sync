defmodule VendorSync.Stripe.EventsPoller do
  use GenServer
  require Logger

  alias VendorSync.Utilities
  alias VendorSync.Stripe.Backfill.Checkpoint

  @default_interval :timer.seconds(1)

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    interval = Keyword.get(opts, :interval, @default_interval)
    schedule_poll(interval)
    {:ok, %{interval: interval}}
  end

  def handle_info(:poll, state) do
    poll_events()
    schedule_poll(state.interval)
    {:noreply, state}
  end

  defp schedule_poll(interval) do
    Process.send_after(self(), :poll, interval)
  end

  defp poll_events do
    with latest_event_id <- Checkpoint.fetch_latest_checkpoint_event_id(),
         {:backfill, latest_event_id} when latest_event_id != nil <- {:backfill, latest_event_id},
         {:ok, events} <- fetch_events(latest_event_id),
         :ok <- upsert_events(events) do
      if event_id = List.first(events)["id"] do
        Checkpoint.update_latest_checkpoint(event_id, length(events))
      end

      :ok
    else
      {:backfill, _} ->
        Logger.warning(
          "No latest checkpoint found for Stripe events poller, have you run VendorSync.Stripe.Backfill.run() ???"
        )
    end
  end

  defp fetch_events(last_event_id) do
    url = "https://api.stripe.com/v1/events"
    headers = [{"Authorization", "Bearer #{Utilities.secret_key()}"}]

    params = %{
      "limit" => 100,
      "ending_before" => last_event_id
    }

    case Req.get(url, headers: headers, params: params) do
      {:ok, %Req.Response{status: status, body: body}} when status in 200..299 ->
        {:ok, body["data"]}

      {:ok, response} ->
        {:error, response}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp upsert_events([]), do: :ok

  defp upsert_events(events) do
    objects =
      for event <- events do
        object = get_in(event, ["data", "object"])

        schema =
          VendorSync.Stripe.Schemas.all_schemas()
          |> Enum.find(fn schema -> schema.object_type == object["object"] end)

        with {:schema, schema} when schema != nil <- {:schema, schema},
             changeset <- Utilities.cast_all(schema.__struct__, object),
             %{valid?: true} <- changeset,
             object <- Ecto.Changeset.apply_changes(changeset) do
          object
        else
          {:schema, _} ->
            Logger.error("No schema found for event: #{inspect(event)}")
            nil
        end
      end
      |> Enum.filter(&(&1 != nil))

    grouped_objects = objects |> Enum.group_by(fn object -> object.__struct__ end)

    for {schema, objects} <- grouped_objects do
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

    :ok
  end
end
