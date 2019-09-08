defmodule Bandsaw.Web.ProjectLive.Index do
  @moduledoc """
  Displays a list of project records and allows for
  creation of new projects.
  """
  use Bandsaw.Web, :live
  alias Bandsaw.Project

  def mount(_session, socket) do
    {:ok, assign(socket, %{
      projects: Project.list(count: :entries)
    })}
  end

  def handle_event("select", id, socket),
    do: {:noreply, live_redirect(socket, to: Routes.live_path(socket, Bandsaw.Web.EnvironmentLive.Index, id))}
  def handle_event("maybe-delete", id, %{assigns: %{projects: projects}} = socket),
    do: {:noreply, assign(socket, :projects, Enum.map(projects, fn p ->
      if String.to_integer(id) == p.id do Map.put(p, :is_deleting?, true) else p end
    end))}
  def handle_event("confirm-delete", id,  %{assigns: %{projects: projects}} = socket) do
    with  project when project != nil <- Enum.find(projects, fn p -> p.id == String.to_integer(id) end),
          true                        <- project.is_deleting?,
          {:ok, _project}             <- Bandsaw.delete_project(project) do
      {:noreply, assign(socket, :projects, Enum.filter(projects, fn p -> p.id != project.id end))}
    else
      _ -> {:noreply, socket}
    end
  end
  def handle_event("cancel-delete", id,  %{assigns: %{projects: projects}} = socket),
    do: {:noreply, assign(socket, :projects, Enum.map(projects, fn p ->
      if String.to_integer(id) == p.id do Map.put(p, :is_deleting?, false) else p end
    end))}
  def handle_event("new", _, socket),
    do: {:noreply, live_redirect(socket, to: Routes.live_path(socket, Bandsaw.Web.ProjectLive.New))}

  def render(assigns),
    do: Bandsaw.Web.ProjectView.render("index.html", assigns)
end
