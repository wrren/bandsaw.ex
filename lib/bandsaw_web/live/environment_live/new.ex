defmodule Bandsaw.Web.EnvironmentLive.New do
  use Bandsaw.Web, :live
  alias Bandsaw.{
    Environment,
    Web.EnvironmentLive
  }

  def mount(id, socket) when is_binary(id),
    do: mount(%{project: id}, socket)
  def mount(%{path_params: %{"id" => id}}, socket),
    do: mount(%{project: id}, socket)
  def mount(%{project: id}, socket) do
    project   = Bandsaw.get_project!(id: id)
    changeset = project
    |> Ecto.build_assoc(:environments)
    |> Environment.changeset(%{})

    {:ok, assign(socket, %{
      project:   project,
      changeset: changeset
    })}
  end

  def render(assigns),
    do: Bandsaw.Web.EnvironmentView.render("form.html", assigns)

  def handle_event("validate", %{"environment" => params}, %{assigns: %{project: project}} = socket) do
    changeset = project
    |> Ecto.build_assoc(:environments)
    |> Environment.changeset(params)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"environment" => params}, %{assigns: %{project: project}} = socket) do
    case Bandsaw.create_environment(params) do
      {:ok, _environment} ->
        {:stop,
          socket
          |> put_flash(:info, "Environment Created")
          |> redirect(to: Routes.live_path(Bandsaw.Web.Endpoint, EnvironmentLive.Index, project.id))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
