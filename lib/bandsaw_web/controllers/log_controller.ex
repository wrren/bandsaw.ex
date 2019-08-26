defmodule Bandsaw.Web.LogController do
  @moduledoc """
  Accepts incoming logs from applications.
  """
  use Bandsaw.Web, :controller

  @doc """
  Create a new log entry
  """
  def write(%{assigns: %{environment: environment}} = conn, %{"log_entries" => entries}) do
    entries
    |> Enum.map(fn entry -> Map.put(entry, "environment_id", environment.id) end)
    |> Enum.each(&Bandsaw.LogEntry.create/1)

    conn
    |> send_resp(:no_content, "")
  end
end
