defmodule Bandsaw.Web.ProjectPlug do
  @moduledoc """
  Enforces the presence and correctness of project authentication
  headers in incoming requests
  """
  import Plug.Conn
  alias Bandsaw.{
    Project,
    Environment
  }

  def init(opts),
    do: {:ok, opts}

  def call(conn, _opts) do
    with  [id]                          <- get_req_header(conn, "x-project-id"),
          [key]                         <- get_req_header(conn, "x-project-key"),
          [env]                         <- get_req_header(conn, "x-project-environment"),
          %Project{} = project          <- Project.one(id: id, key: key, environment: env),
          %Environment{} = environment  <- Environment.one(id: env, project: project) do
      conn
      |> assign(:project,     project)
      |> assign(:environment, environment)
    else
      nil ->
        conn
        |> put_status(:not_found)
        |> halt
      _ ->
        conn
        |> put_status(:forbidden)
        |> halt
    end
  end
end
