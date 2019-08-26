defmodule Bandsaw.Project do
  use Bandsaw.Schema
  alias Bandsaw.{
    Events,
    Environment
  }

  schema "projects" do
    field :name,        :string

    has_many :environments, Environment

    timestamps()
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
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
  def one!(opts) when is_list(opts) and length(opts) > 0 do
    __MODULE__
    |> build_query(opts)
    |> Repo.one!
  end

  @doc """
  Create a new record
  """
  def create(params) do
    %__MODULE__{}
    |> changeset(params)
    |> Repo.insert
    |> Events.project_created()
  end
  def create!(params) do
    %__MODULE__{}
    |> changeset(params)
    |> Repo.insert!
    |> Events.project_created()
  end

  @doc """
  Update an existing record
  """
  def update(struct, params) do
    struct
    |> changeset(params)
    |> Repo.update
    |> Events.project_updated(struct)
  end
  def update!(struct, params) do
    struct
    |> changeset(params)
    |> Repo.update!
    |> Events.project_updated(struct)
  end

  @doc """
  Delete a record
  """
  def delete(%__MODULE__{} = struct),
    do: Repo.delete(struct)
  def delete!(%__MODULE__{} = struct),
    do: Repo.delete!(struct)

  @doc false
  defp build_query(query, [{:name, name} | t]),
    do: build_query(where(query, [p], p.name == ^name), t)
  defp build_query(query, opts),
    do: Repo.build_query(query, opts, &(build_query(&1, &2)))
end
