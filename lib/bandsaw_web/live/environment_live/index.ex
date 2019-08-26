defmodule Bandsaw.Web.EnvironmentLive.Index do
  @moduledoc """
  Displays a list of Environments associated with a given Project
  """
  use Bandsaw.Web, :live

  def mount(%{path_params: %{"id" => id}}, socket) do
    {:ok, assign(socket, %{
      project:      Bandsaw.get_project(id: id),
      environments: Bandsaw.list_environments(project: id)
    })}
  end

  def render(assigns),
    do: Bandsaw.Web.EnvironmentView.render("index.html", assigns)
end
