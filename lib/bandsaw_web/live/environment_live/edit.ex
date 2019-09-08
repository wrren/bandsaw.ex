defmodule Bandsaw.Web.EnvironmentLive.Edit do
  use Bandsaw.Web, :live
  alias Bandsaw.{
    Environment,
    Web.EnvironmentLive
  }

  def mount(id, socket) when is_binary(id),
    do: mount(%{environment: id}, socket)
  def mount(%{path_params: %{"id" => id}}, socket),
    do: mount(%{environment: id}, socket)
  def mount(%{environment: id}, socket) do
    environment = Bandsaw.get_environment!(id: id)
    changeset   = Environment.changeset(environment, %{})

    {:ok, assign(socket, %{
      environment:  environment,
      changeset:    changeset
    })}
  end

  def render(assigns),
    do: Bandsaw.Web.EnvironmentView.render("form.html", assigns)

  def handle_event("validate", %{"environment" => params}, %{assigns: %{environment: environment}} = socket) do
    {:noreply, assign(socket, changeset: Environment.changeset(environment, params))}
  end

  def handle_event("save", %{"environment" => params}, %{assigns: %{environment: environment}} = socket) do
    case Bandsaw.update_environment(environment, params) do
      {:ok, _environment} ->
        {:stop,
          socket
          |> put_flash(:info, "Environment Updated")
          |> redirect(to: Routes.live_path(Bandsaw.Web.Endpoint, EnvironmentLive.Index, environment.project_id))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
