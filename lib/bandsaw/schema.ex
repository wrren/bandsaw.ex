defmodule Bandsaw.Schema do
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      import Ecto.Query
      import EctoEnum, only: [defenum: 2]

      alias Bandsaw.Repo
    end
  end
end
