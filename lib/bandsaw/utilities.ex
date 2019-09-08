defmodule Bandsaw.Utilities do
  @doc """
  Derive an ID from a given value
  """
  def id(%{id: id}),
    do: id(id)
  def id(%{"id" => id}),
    do: id(id)
  def id(id) when is_binary(id),
    do: id(String.to_integer(id))
  def id(id) when is_integer(id),
    do: id
end
