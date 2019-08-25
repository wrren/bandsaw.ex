defmodule Bandsaw.Web.LogEntryLive.Index do
  use Bandsaw.Web, :live
  alias Bandsaw.LogEntry
  require Logger

  def mount(%{path_params: %{"project" => id}}, socket) do
    Event.Adapter.start_link([Bandsaw.Events], self())
    {:ok, assign(socket, %{
      project_id: String.to_integer(id),
      limit:      50,
      entries:    LogEntry.list(project: String.to_integer(id), order_by: {:timestamp, :desc}, limit: 50)
    })}
  end
  def mount(_session, socket) do
    Event.Adapter.start_link([Bandsaw.Events], self())
    {:ok, assign(socket, %{
      project_id: nil,
      limit:      50,
      entries:    LogEntry.list(order_by: {:timestamp, :desc}, limit: 50)
    })}
  end

  def render(assigns),
    do: Bandsaw.Web.LogEntryView.render("index.html", assigns)

  def handle_event("log", _value, socket) do
    Logger.error "Created Log Entry"
    {:noreply, socket}
  end

  def handle_info({:log_entry_created, %LogEntry{project_id: id} = entry}, %{assigns: %{project_id: id} = assigns} = socket) do
    {:noreply, assign(socket, :entries, Enum.take([entry | assigns.entries], assigns.limit))}
  end
  def handle_info({:log_entry_created, %LogEntry{} = entry}, %{assigns: %{project_id: nil} = assigns} = socket) do
    {:noreply, assign(socket, :entries, Enum.take([entry | assigns.entries], assigns.limit))}
  end
  def handle_info(_, socket),
    do: {:noreply, socket}
end
