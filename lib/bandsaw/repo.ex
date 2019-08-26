defmodule Bandsaw.Repo do
  use Ecto.Repo,
    otp_app: :bandsaw,
    adapter: Ecto.Adapters.Postgres

  import Ecto.Query

  @doc """
  Apply common query options to filter and limit the given query
  """
  def build_query(query, [{:limit, limit} | t], next) do
    query
    |> limit(^limit)
    |> next.(t)
  end
  def build_query(query, [{:offset, offset} | t], next) do
    query
    |> offset(^offset)
    |> next.(t)
  end
  def build_query(query, [{:id, id} | t], next) when is_binary(id) do
    query
    |> where([r], r.id == ^String.to_integer(id))
    |> next.(t)
  end
  def build_query(query, [{:id, %_{id: id}} | t], next) do
    query
    |> where([r], r.id == ^id)
    |> next.(t)
  end
  def build_query(query, [{:id, id} | t], next) when is_integer(id) do
    query
    |> where([r], r.id == ^id)
    |> next.(t)
  end
  def build_query(query, [], _next),
    do: query
end
