defmodule Bandsaw.Web.ProjectLive.Edit do
  use Bandsaw.Web, :live
  alias Bandsaw.Project

  def mount(id, socket) when is_binary(id),
    do: mount(%{project: id}, socket)
  def mount(%{path_params: %{"id" => id}}, socket),
    do: mount(%{project: id}, socket)
  def mount(%{project: id}, socket) do
    project   = Bandsaw.get_project!(id: id)
    changeset = Project.changeset(project)

    {:ok, assign(socket, %{
      project:   project,
      changeset: changeset
    })}
  end

  def render(assigns),
    do: Bandsaw.Web.ProjectView.render("form.html", assigns)

  def handle_event("validate", %{"project" => params}, %{assigns: %{project: project}} = socket) do
    {:noreply, assign(socket, changeset: Project.changeset(project, params))}
  end

  def handle_event("save", %{"project" => params}, %{assigns: %{project: project}} = socket) do
    case Bandsaw.update_project(project, params) do
      {:ok, _project} ->
        {:stop,
          socket
          |> put_flash(:info, "Project Updated")
          |> redirect(to: Routes.live_path(Bandsaw.Web.Endpoint, Bandsaw.Web.ProjectLive.Index))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
