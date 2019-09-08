defmodule Bandsaw.Web.NavigationLive.Show do
  @moduledoc """
  Controls the left navigation menu and modifies content
  based on the session parameters passed to it.
  """
  use Bandsaw.Web, :live

  @limit_increment 10

  def mount(%{context: :root}, socket) do
    Event.Adapter.start_link([Bandsaw.Events], self())
    {:ok, assign(socket, %{
      context:  :root,
      projects: Bandsaw.list_projects()
    })}
  end
  def mount(%{context: :project, id: id}, socket) do
    Event.Adapter.start_link([Bandsaw.Events], self())
    {:ok, assign(socket, %{
      context:      :project,
      projects:     Enum.map(Bandsaw.list_projects(), fn p -> if p.id == id do Map.put(p, :is_active?, true) else p end end),
      project_id:   id,
      environments: Bandsaw.list_environments(project: id)
    })}
  end
  def mount(%{context: :environment, id: id, project_id: project_id, listener: pid}, socket) do
    Event.Adapter.start_link([Bandsaw.Events], self())
    {:ok, assign(socket, %{
      context:      :environment,
      projects:     Enum.map(Bandsaw.list_projects(), fn p ->
        if p.id == project_id do Map.put(p, :is_active?, true) else p end
      end),
      project_id:   id,
      environments: Enum.map(Bandsaw.list_environments(project: project_id), fn e ->
        if e.id == id do Map.put(e, :is_active?, true) else e end
      end),
      levels: Enum.map(Bandsaw.LogEntry.Level.__enum_map__(), fn {name, value} ->
        %{name: name, is_active?: true, count: Bandsaw.count_log_entries(level: name, environment: id)}
      end),
      listener:     pid,
      limit:        100
    })}
  end
  def mount(_, socket),
    do: mount(%{context: :root}, socket)

  def render(assigns),
    do: Bandsaw.Web.LayoutView.render("nav.html", assigns)

  def handle_event("level", name, %{assigns: %{listener: listener, levels: levels}} = socket) do
    with level when level != nil <- Enum.find(levels, fn l -> Atom.to_string(l.name) == name end) do
      send(listener, {:update_filter, level.name, not level.is_active?})
      {:noreply, assign(socket, :levels, Enum.map(levels, fn l ->
        if Atom.to_string(l.name) == name do %{l | is_active?: not l.is_active?} else l end
      end))}
    else
      _ -> {:noreply, socket}
    end
  end
  def handle_event("limit-up", _, %{assigns: %{limit: limit, listener: listener}} = socket) when limit < 500 do
    send(listener, {:update_limit, limit + @limit_increment})
    {:noreply, assign(socket, :limit, limit + @limit_increment)}
  end
  def handle_event("limit-down", _, %{assigns: %{limit: limit, listener: listener}} = socket) when limit > @limit_increment do
    send(listener, {:update_limit, limit - @limit_increment})
    {:noreply, assign(socket, :limit, limit - @limit_increment)}
  end
  def handle_event(_, _, socket),
    do: {:noreply, socket}

  def handle_info({:project_created, new}, %{assigns: %{projects: projects}} = socket),
    do: {:noreply, assign(socket, :projects, projects ++ [new])}
  def handle_info({:project_deleted, deleted}, %{assigns: %{projects: projects}} = socket),
    do: {:noreply, assign(socket, :projects, Enum.filter(projects, fn p -> p.id != deleted.id end))}
  def handle_info({:project_updated, _old, new}, %{assigns: %{projects: projects}} = socket),
    do: {:noreply, assign(socket, :projects, Enum.map(projects, fn p -> if p.id == new.id do new else p end end))}
  def handle_info(_info, socket),
    do: {:noreply, socket}
end
