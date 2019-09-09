defmodule Bandsaw.Web.LogEntryLive.Index do
  use Bandsaw.Web, :live
  alias Bandsaw.LogEntry
  require Logger

  def mount(%{path_params: %{"id" => id}}, socket) do
    Event.Adapter.start_link([Bandsaw.Events], self())
    send(self(), :refresh_timestamp)
    {:ok, select_environment(id, socket)}
  end

  #
  # Select a new Environment
  #
  defp select_environment(id, %{assigns: %{environment: %{id: id}}} = socket),
    do: socket
  defp select_environment(id, socket) do
    with  {:environment, environment} when environment != nil <- {:environment, Bandsaw.get_environment(id: id)},
          {:project, project}                                 <- {:project, Bandsaw.get_project(id: environment.project_id)} do
      assign(socket, %{
        project:      project,
        environment:  environment,
        self:         self(),
        limit:        100,
        levels:       [:error, :warn, :debug, :info],
        refresh:      :tick
      })
      |> load_entries()
    else
      _ -> socket
    end
  end

  @doc false
  def load_entries(%{assigns: %{environment: environment, levels: levels, limit: limit}} = socket) do
    assign(socket, :entries, Enum.map(Bandsaw.list_log_entries(
      level: levels,
      environment: environment,
      order_by: {:timestamp, :desc},
      limit: limit
    ), &(add_from_now(&1))))
  end

  def render(assigns),
    do: Bandsaw.Web.LogEntryView.render("index.html", assigns)

  def handle_params(%{"id" => id}, _url, socket),
    do: {:noreply, select_environment(String.to_integer(id), socket)}
  def handle_params(_params, _url, socket),
    do: {:noreply, socket}

  def handle_info({:update_limit, limit}, socket),
    do: {:noreply, load_entries(assign(socket, :limit, limit))}
  def handle_info({:update_filter, level, true}, %{assigns: %{levels: levels}} = socket),
    do: {:noreply, load_entries(assign(socket, :levels, Enum.uniq([level | levels])))}
  def handle_info({:update_filter, level, false}, %{assigns: %{levels: levels}} = socket),
    do: {:noreply, load_entries(assign(socket, :levels, Enum.filter(levels, fn l -> l != level end)))}
  def handle_info({:log_entry_created, %LogEntry{environment_id: id} = entry}, %{assigns: %{environment: %{id: id}}} = socket) do
    {:noreply, maybe_add_entry(socket, entry)}
  end
  def handle_info(:refresh_timestamp, %{assigns: %{entries: entries}} = socket) do
    Process.send_after(self(), :refresh_timestamp, :timer.seconds(1))
    {:noreply, assign(socket, :entries, Enum.map(entries, &(add_from_now(&1))))}
  end
  def handle_info(_, socket),
    do: {:noreply, socket}

  @doc false
  defp maybe_add_entry(%{assigns: %{levels: levels, entries: entries, limit: limit}} = socket, %LogEntry{level: level} = entry) do
    if Enum.member?(levels, level) do
      assign(socket, :entries, Enum.take([add_from_now(entry) | entries], limit))
    else
      socket
    end
  end
  defp maybe_add_entry(socket, _entry),
    do: socket

  defp add_from_now(%LogEntry{timestamp: timestamp} = entry),
    do: Map.put(entry, :from_now, Timex.from_now(timestamp))
end
