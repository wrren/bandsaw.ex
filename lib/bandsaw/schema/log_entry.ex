defmodule Bandsaw.LogEntry do
  use Bandsaw.Schema
  alias Bandsaw.Environment
  alias Bandsaw.Events
  import Bandsaw.Utilities

  defenum Level, debug: 0, info: 1, warn: 2, error: 3

  schema "log_entries" do
    field :level,             Level
    field :message,           :string
    field :timestamp,         :utc_datetime

    belongs_to :environment,  Environment
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:level, :message, :timestamp, :environment_id])
    |> validate_required([:level, :message, :timestamp])
    |> validate_inclusion(:level, Level.__valid_values__())
    |> foreign_key_constraint(:environment_id)
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
    |> Events.log_entry_created()
  end
  def create!(params) do
    %__MODULE__{}
    |> changeset(params)
    |> Repo.insert!
    |> Events.log_entry_created()
  end

  @doc """
  Update an existing record
  """
  def update(struct, params) do
    struct
    |> changeset(params)
    |> Repo.update
  end
  def update!(struct, params) do
    struct
    |> changeset(params)
    |> Repo.update!
  end

  @doc """
  Count log entries returned by the given query constraints
  """
  def count(opts \\ []) do
    __MODULE__
    |> build_query(opts)
    |> Repo.aggregate(:count, :id)
  end

  @doc """
  Delete a record
  """
  def delete(%__MODULE__{} = struct),
    do: Repo.delete(struct)
  def delete!(%__MODULE__{} = struct),
    do: Repo.delete!(struct)

  @doc false
  defp build_query(query, [{:environment, environment} | t]),
    do: build_query(where(query, [l], l.environment_id == ^id(environment)), t)
  defp build_query(query, [{:project, project} | t]) do
    query
    |> join(:inner, [l], e in assoc(l, :environment), as: :environment)
    |> join(:inner, [l, environment: e], p in assoc(e, :project), on: p.id == e.project_id and p.id == ^id(project))
    |> build_query(t)
  end
  defp build_query(query, [{:level, levels} | t]) when is_list(levels),
    do: build_query(where(query, [l], l.level in ^levels), t)
  defp build_query(query, [{:level, level} | t]),
    do: build_query(where(query, [l], l.level == ^level), t)
  defp build_query(query, [{:order_by, {:timestamp, :desc}} | t]) do
    query
    |> order_by([l], desc: l.timestamp, desc: l.id)
    |> build_query(t)
  end
  defp build_query(query, opts),
    do: Repo.build_query(query, opts, &(build_query(&1, &2)))
end
