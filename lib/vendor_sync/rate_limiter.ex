defmodule VendorSync.RateLimiter do
  @moduledoc false

  use GenServer

  # Client API
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def enter(pid, func, opts \\ []) do
    timeout = Keyword.get(opts, :timeout, 5000)
    GenServer.call(pid, :enter, timeout)
    func.()
  end

  # Server callbacks
  def init(opts) do
    messages = Keyword.fetch!(opts, :messages)
    interval = Keyword.fetch!(opts, :interval)

    state = %{
      messages: messages,
      interval: interval,
      sent: 0,
      queue: [],
      timer_ref: nil
    }

    {:ok, schedule_tick(state)}
  end

  def handle_call(:enter, from, %{queue: queue} = state) do
    if state.sent < state.messages do
      {:reply, :ok, %{state | sent: state.sent + 1}}
    else
      {:noreply, %{state | queue: queue ++ [from], sent: state.sent + 1}}
    end
  end

  def handle_info(:tick, %{queue: []} = state) do
    {:noreply, schedule_tick(%{state | sent: state.sent - 1})}
  end

  def handle_info(:tick, %{queue: [from | rest_queue]} = state) do
    GenServer.reply(from, :ok)
    {:noreply, schedule_tick(%{state | queue: rest_queue})}
  end

  # Helper functions
  defp schedule_tick(state) do
    interval_ms_per_msg = div(state.interval, state.messages)
    timer_ref = Process.send_after(self(), :tick, interval_ms_per_msg)
    %{state | timer_ref: timer_ref}
  end
end
