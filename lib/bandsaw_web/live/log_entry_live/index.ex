defmodule Bandsaw.Web.LogEntryLive.Index do
  use Bandsaw.Web, :live
  alias Bandsaw.LogEntry
  require Logger

  def mount(%{path_params: %{"id" => id}}, socket) do
    Event.Adapter.start_link([Bandsaw.Events], self())
    {:ok, select_environment(id, socket)}
  end
  def mount(_session, socket) do
    Event.Adapter.start_link([Bandsaw.Events], self())
    {:ok, select_environment(socket)}
  end

  #
  # Select a new Environment
  #
  defp select_environment(socket) do
    with  {:projects, [project | _] = projects}   <- {:projects, Bandsaw.list_projects(join: :environments)},
          {:environments, [environment | _]}      <- {:environments, project.environment} do
      assign(socket, %{
        projects:     projects,
        environment:  environment,
        self:         self(),
        limit:        100,
        levels:       [:error, :warn, :debug, :info]
      })
      |> load_entries()
    else
      _ -> socket
    end
  end
  defp select_environment(id, socket) do
    with  {:environment, environment} when environment != nil <- {:environment, Bandsaw.get_environment(id: id)},
          {:projects, projects}                               <- {:projects, Bandsaw.list_projects(join: :environments)} do
      assign(socket, %{
        projects:     projects,
        environment:  environment,
        self:         self(),
        limit:        100,
        levels:       [:error, :warn, :debug, :info]
      })
      |> load_entries()
    else
      _ -> socket
    end
  end

  @doc false
  def load_entries(%{assigns: %{environment: environment, levels: levels, limit: limit}} = socket) do
    assign(socket, :entries, Bandsaw.list_log_entries(
      level: levels,
      environment: environment,
      order_by: {:timestamp, :desc},
      limit: limit
    ))
  end

  def render(assigns),
    do: Bandsaw.Web.LogEntryView.render("index.html", assigns)

  def handle_info({:update_limit, limit}, socket),
    do: {:noreply, load_entries(assign(socket, :limit, limit))}
  def handle_info({:update_filter, level, true}, %{assigns: %{levels: levels}} = socket),
    do: {:noreply, load_entries(assign(socket, :levels, Enum.uniq([level | levels])))}
  def handle_info({:update_filter, level, false}, %{assigns: %{levels: levels}} = socket),
    do: {:noreply, load_entries(assign(socket, :levels, Enum.filter(levels, fn l -> l != level end)))}
  def handle_info({:log_entry_created, %LogEntry{environment_id: id} = entry}, %{assigns: %{environment: %{id: id}} = assigns} = socket) do
    {:noreply, maybe_add_entry(socket, entry)}
  end
  def handle_info(_, socket),
    do: {:noreply, socket}

  @doc false
  defp maybe_add_entry(%{assigns: %{levels: levels, entries: entries, limit: limit}} = socket, %LogEntry{level: level} = entry) do
    if Enum.member?(levels, level) do
      assign(socket, :entries, Enum.take([entry | entries], limit))
    else
      socket
    end
  end
  defp maybe_add_entry(socket, _entry),
    do: socket
end
