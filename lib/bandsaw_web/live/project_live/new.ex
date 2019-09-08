defmodule Bandsaw.Web.ProjectLive.New do
  use Bandsaw.Web, :live
  alias Bandsaw.Project

  def mount(_session, socket) do
    {:ok, assign(socket, %{
      changeset: Project.changeset(%Project{})
    })}
  end

  def render(assigns),
    do: Bandsaw.Web.ProjectView.render("form.html", assigns)

  def handle_event("validate", %{"project" => params}, socket) do
    changeset = %Project{}
    |> Project.changeset(params)
    |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"project" => params}, socket) do
    case Bandsaw.create_project(params) do
      {:ok, project} ->
        {:stop,
          socket
          |> put_flash(:info, "Project Created")
          |> redirect(to: Routes.live_path(Bandsaw.Web.Endpoint, Bandsaw.Web.ProjectLive.Index))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
