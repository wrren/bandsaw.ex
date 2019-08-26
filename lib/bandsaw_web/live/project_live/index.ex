defmodule Bandsaw.Web.ProjectLive.Index do
  @moduledoc """
  Displays a list of project records and allows for
  creation of new projects.
  """
  use Bandsaw.Web, :live
  alias Bandsaw.Project

  def mount(_session, socket) do
    {:ok, assign(socket, %{
      projects: Project.list()
    })}
  end
end
