defmodule Bandsaw.Project do
  use Bandsaw.Schema
  alias Bandsaw.{
    Events,
    Environment,
    LogEntry
  }

  schema "projects" do
    field :name,        :string
    field :description, :string
    field :entry_count, :integer, virtual: true, default: 0

    has_many :environments, Environment

    timestamps()
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :description])
    |> validate_required([:name, :description])
    |> validate_length(:name, min: 3)
    |> validate_length(:description, min: 3)
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
    do: Events.project_deleted(Repo.delete(struct))
  def delete!(%__MODULE__{} = struct),
    do: Events.project_deleted(Repo.delete!(struct))

  @doc false
  defp build_query(query, [{:name, name} | t]),
    do: build_query(where(query, [p], p.name == ^name), t)
  defp build_query(query, [{:count, :entries} | t]) do
    query
    |> join(:left, [p], l in subquery(count_log_entries_query()), on: p.id == l.project_id, as: :count)
    |> select_merge([p, count: c], %{entry_count: c.count})
    |> build_query(t)
  end
  defp build_query(query, [{:join, :environments} | t]) do
    query
    |> join(:left, [p], e in assoc(p, :environments), as: :environments)
    |> preload([p, environments: e], [environments: e])
    |> build_query(t)
  end
  defp build_query(query, opts),
    do: Repo.build_query(query, opts, &(build_query(&1, &2)))

  @doc false
  defp count_log_entries_query do
    LogEntry
    |> join(:inner, [l], e in assoc(l, :environment), as: :environment)
    |> join(:inner, [l, e], p in assoc(e, :project), as: :project)
    |> group_by([project: p], p.id)
    |> select([project: p], %{project_id: p.id, count: count(p.id)})
  end
end
