defmodule Bandsaw.Web.EnvironmentLive.Index do
  @moduledoc """
  Displays a list of Environments associated with a given Project
  """
  use Bandsaw.Web, :live
  alias Bandsaw.LogEntry

  def mount(%{path_params: %{"id" => id}}, socket),
    do: mount(%{project: id}, socket)
  def mount(%{project: id}, socket) do
    Event.Adapter.start_link([Bandsaw.Events], self())
    {:ok, load_environments(socket, id)}
  end

  def render(assigns),
    do: Bandsaw.Web.EnvironmentView.render("index.html", assigns)

  def handle_params(%{"id" => id}, _url, socket),
    do: {:noreply, load_environments(socket, String.to_integer(id))}
  def handle_params(_params, _url, socket),
    do: {:noreply, socket}

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

  def handle_info({:log_entry_created,entry}, socket),
    do: {:noreply, update_entry_count(socket, entry)}
  def handle_info(_info, socket),
    do: {:noreply, socket}

  defp load_environment(%{assigns: %{project: %{id: id}}} = socket, _id),
    do: socket
  defp load_environments(socket, project_id) do
    socket
    |> assign(%{
      project:      Bandsaw.get_project(id: project_id),
      environments: Bandsaw.list_environments(project: project_id, count: :entries)
    })
  end

  @doc false
  defp update_entry_count(%{assigns: %{environments: environments}} = socket, %LogEntry{environment_id: id}) do
    socket
    |> assign(:environments, Enum.map(environments, fn %{entry_count: count} = environment ->
      if environment.id == id do
        %{environment | entry_count: count + 1}
      else
        environment
      end
    end))
  end
end
