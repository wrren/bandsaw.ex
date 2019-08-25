defmodule Bandsaw.Project do
  use Bandsaw.Schema

  defenum Environment, production: 0, development: 1

  schema "projects" do
    field :name,        :string
    field :key,         :string
    field :environment, Environment

    timestamps()
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :key, :environment])
    |> maybe_put_key(:key)
    |> validate_required([:name, :key])
    |> validate_inclusion(:environment, Environment.__valid_values__())
    |> unique_constraint(:key)
    |> unique_constraint(:environment, name: :projects_name_environment_index)
  end

  @doc """
  List records, optionally filtering and limiting results using the given query options
  """
  def list(opts \\ []) do
    __MODULE__
    |> build_query(opts)
    |> Repo.all
  end

  @doc """
  Get a single record that satisfies the given query options
  """
  def one(opts) when is_list(opts) and length(opts) > 0 do
    __MODULE__
    |> build_query(opts)
    |> Repo.one
  end

  @doc """
  Create a new record
  """
  def create(params) do
    %__MODULE__{}
    |> changeset(params)
    |> Repo.insert
  end

  @doc """
  Update an existing record
  """
  def update(struct, params) do
    struct
    |> changeset(params)
    |> Repo.update
  end

  @doc """
  Delete a record
  """
  def delete(struct) do
    struct
    |> Repo.delete
  end

  #
  # Put an application key in the given changeset if one isn't already present
  #
  defp maybe_put_key(changeset, field) do
    case get_field(changeset, field) do
      nil -> put_change(changeset, field, make_key())
      _   -> changeset
    end
  end

  #
  # Generate an application key
  #
  defp make_key(length \\ 32) do
    length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64()
  end

  @doc false
  defp build_query(query, [{:name, name} | t]),
    do: build_query(where(query, [p], p.name == ^name), t)
  defp build_query(query, [{:key, key} | t]),
    do: build_query(where(query, [p], p.key == ^key), t)
  defp build_query(query, [{:environment, env} | t]),
    do: build_query(where(query, [p], p.environment == ^env), t)
  defp build_query(query, opts),
    do: Repo.build_query(query, opts, &(build_query(&1, &2)))

  use Bandsaw.Schema, :crud
end
