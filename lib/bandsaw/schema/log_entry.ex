defmodule Bandsaw.LogEntry do
  use Bandsaw.Schema
  alias Bandsaw.Project
  alias Bandsaw.Events

  defenum Level, debug: 0, info: 1, warn: 2, error: 3

  schema "log_entries" do
    field :level,         Level
    field :message,       :string
    field :timestamp,     :utc_datetime

    belongs_to :project,  Project
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:level, :message, :timestamp, :project_id])
    |> validate_required([:level, :message, :timestamp])
    |> validate_inclusion(:level, Level.__valid_values__())
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

  @doc """
  Delete a record
  """
  def delete(struct) do
    struct
    |> Repo.delete
  end

  @doc false
  defp build_query(query, [{:project, id} | t]),
    do: build_query(where(query, [l], l.project_id == ^id), t)
  defp build_query(query, [{:level, level} | t]),
    do: build_query(where(query, [l], l.level == ^level), t)
  defp build_query(query, [{:order_by, {:timestamp, :desc}} | t]) do
    query
    |> order_by([l], desc: l.timestamp)
    |> build_query(t)
  end
  defp build_query(query, opts),
    do: Repo.build_query(query, opts, &(build_query(&1, &2)))
end
