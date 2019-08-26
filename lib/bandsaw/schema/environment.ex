defmodule Bandsaw.Environment do
  @moduledoc """
  Represents an environment, e.g production, staging,
  development, etc. for a particular Project.
  """
  use Bandsaw.Schema
  alias Bandsaw.{
    Events,
    Project,
    LogEntry,
    Environment
  }

  schema "environments" do
    field :name,        :string
    field :key,         :string
    field :entry_count, :integer, virtual: true

    belongs_to  :project,     Project
    has_many    :log_entries, LogEntry

    timestamps()
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :key, :project_id])
    |> maybe_put_key(:key)
    |> validate_required([:name, :key])
    |> validate_length(:name, min: 3)
    |> unique_constraint(:name, name: :environments_project_id_name_index)
    |> foreign_key_constraint(:project_id)
  end

  @doc """
  List all Environment records that satisfy the given query constraints.

  ## Options

    * `:name` - Query for Environments with the given name
    * `:project` - Wuery for Environments associated with the given project
    * `:limit` - Limit the number of returned results to the given number
    * `:offset` - Return query results from the given offset

  """
  def list(opts \\ []) do
    Environment
    |> build_query(opts)
    |> Repo.all
  end

  @doc """
  Get an Environment record that satisfies the given query constraints.

  ## Options

    * `:id` - Query for an Environment with the given ID
    * `:name` - Query for Environments with the given name
    * `:project` - Wuery for Environments associated with the given project

  """
  def one(opts) when is_list(opts) and length(opts) > 0 do
    Environment
    |> build_query(opts)
    |> Repo.one
  end
  def one!(opts) when is_list(opts) and length(opts) > 0 do
    Environment
    |> build_query(opts)
    |> Repo.one!
  end

  @doc """
  Create a new Environment record
  """
  def create(params) do
    %Environment{}
    |> changeset(params)
    |> Repo.insert
    |> Events.environment_created()
  end
  def create!(params) do
    %Environment{}
    |> changeset(params)
    |> Repo.insert!
    |> Events.environment_created()
  end

  @doc """
  Update an Environment record
  """
  def update(%Environment{} = struct, params) do
    struct
    |> changeset(params)
    |> Repo.update
    |> Events.environment_updated(struct)
  end
  def update!(%Environment{} = struct, params) do
    struct
    |> changeset(params)
    |> Repo.update!
    |> Events.environment_updated(struct)
  end

  @doc """
  Delete an Environment struct
  """
  def delete(%Environment{} = struct),
    do: Repo.delete(struct)
  def delete!(%Environment{} = struct),
    do: Repo.delete!(struct)

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
    do: build_query(where(query, [e], e.name == ^name), t)
  defp build_query(query, [{:project, project_id} | t]) when is_integer(project_id),
    do: build_query(where(query, [e], e.project_id == ^project_id), t)
  defp build_query(query, [{:project, %Project{id: project_id}} | t]),
    do: build_query(where(query, [e], e.project_id == ^project_id), t)
  defp build_query(query, [{:count, :entries} | t]) do
    query
    |> join(:left, [e], l in subquery(count_log_entries_query()), on: e.id == l.environment_id, as: :count)
    |> select_merge([e, count: c], %{entry_count: c.count})
    |> build_query(t)
  end
  defp build_query(query, opts),
    do: Repo.build_query(query, opts, &(build_query(&1, &2)))

  @doc false
  defp count_log_entries_query do
    LogEntry
    |> group_by([l], l.environment_id)
    |> select([l], %{environment_id: l.environment_id, count: count(l.environment_id)})
  end
end
