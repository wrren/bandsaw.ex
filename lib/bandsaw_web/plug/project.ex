defmodule Bandsaw.Web.ProjectPlug do
  @moduledoc """
  Enforces the presence and correctness of project authentication
  headers in incoming requests
  """
  import Plug.Conn
  alias Bandsaw.Project

  def init(opts),
    do: {:ok, opts}

  def call(conn, _opts) do
    with  [id]                        <- get_req_header(conn, "x-application-id"),
          [key]                       <- get_req_header(conn, "x-application-key"),
          env                         <- get_req_header(conn, "x-application-environment"),
          env                         <- Enum.at(env, 0, "production"),
          project when project != nil <- Project.one(id: id, key: key, environment: env) do
      conn
      |> assign(:project, project)
    else
      _ ->
        conn
        |> put_status(:forbidden)
        |> halt
    end
  end
end
