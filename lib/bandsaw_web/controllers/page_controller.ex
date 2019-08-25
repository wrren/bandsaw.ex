defmodule Bandsaw.Web.PageController do
  use Bandsaw.Web, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
