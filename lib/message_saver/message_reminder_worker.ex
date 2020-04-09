defmodule MessageSaver.MessageReminderWorker do
  use GenServer

  alias MessageSaver.MessageHandler

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    poll()

    {:ok, state}
  end

  def handle_info(:check_for_reminders, state) do
    MessageHandler.send_reminders()
    poll()

    {:noreply, state}
  end

  defp poll do
    Process.send_after(self(), :check_for_reminders, 60_000)
  end
end
