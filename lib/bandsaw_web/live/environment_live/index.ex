defmodule Bandsaw.Web.EnvironmentLive.Index do
  @moduledoc """
  Displays a list of Environments associated with a given Project
  """
  use Bandsaw.Web, :live

  def mount(id, socket) when is_binary(id),
    do: mount(%{project: id}, socket)
  def mount(%{project: id}, socket) do
    {:ok, assign(socket, %{
      project:      Bandsaw.get_project(id: id),
      environments: Bandsaw.list_environments(project: id, count: :entries)
    })}
  end
  def mount(%{path_params: %{"id" => id}}, socket),
    do: mount(%{project: id}, socket)

  def render(assigns),
    do: Bandsaw.Web.EnvironmentView.render("index.html", assigns)

  def handle_event("maybe-delete", id, %{assigns: %{environments: environments}} = socket),
    do: {:noreply, assign(socket, :environments, Enum.map(environments, fn e ->
      if String.to_integer(id) == e.id do Map.put(e, :is_deleting?, true) else e end
    end))}
  def handle_event("confirm-delete", id,  %{assigns: %{environments: environments}} = socket) do
    with  environment when environment != nil <- Enum.find(environments, fn e -> e.id == String.to_integer(id) end),
          true                                <- environment.is_deleting?,
          {:ok, _environment}                 <- Bandsaw.delete_project(environment) do
      {:noreply, assign(socket, :environments, Enum.filter(environments, fn e -> e.id != environment.id end))}
    else
      _ -> {:noreply, socket}
    end
  end
  def handle_event("cancel-delete", id,  %{assigns: %{environments: environments}} = socket),
    do: {:noreply, assign(socket, :environments, Enum.map(environments, fn e ->
      if String.to_integer(id) == e.id do Map.put(e, :is_deleting?, false) else e end
    end))}
  def handle_event("new", _, %{assigns: %{project: project}} = socket),
    do: {:noreply, live_redirect(socket, to: Routes.live_path(socket, Bandsaw.Web.EnvironmentLive.New, project.id))}
end
