defmodule Bandsaw.Events do
  use Event.Source, name: __MODULE__, max_events: 1_000
  alias Bandsaw.{
    Project,
    Environment,
    LogEntry
  }

  @doc false
  def project_created({:ok, project}) do
    async_notify(__MODULE__, {:project_created, project})
    {:ok, project}
  end
  def project_created(%Project{} = project) do
    async_notify(__MODULE__, {:project_created, project})
    project
  end
  def project_created(other),
    do: other

  @doc false
  def project_updated({:ok, %Project{} = new}, %Project{} = old) do
    async_notify(__MODULE__, {:project_updated, old, new})
    {:ok, new}
  end
  def project_updated(%Project{} = new, %Project{} = old) do
    async_notify(__MODULE__, {:project_updated, old, new})
    new
  end
  def project_updated(other, _old),
    do: other

  @doc false
  def project_deleted({:ok, project}) do
    async_notify(__MODULE__, {:project_deleted, project})
    {:ok, project}
  end
  def project_deleted(%Project{} = project) do
    async_notify(__MODULE__, {:project_deleted, project})
    project
  end
  def project_deleted(other),
    do: other

  @doc false
  def environment_created({:ok, environment}) do
    async_notify(__MODULE__, {:environment_created, environment})
    {:ok, environment}
  end
  def environment_created(%Environment{} = environment) do
    async_notify(__MODULE__, {:environment_created, environment})
    environment
  end
  def environment_created(other),
    do: other

  @doc false
  def environment_updated({:ok, %Environment{} = new}, %Environment{} = old) do
    async_notify(__MODULE__, {:environment_updated, old, new})
    {:ok, new}
  end
  def environment_updated(%Environment{} = new, %Environment{} = old) do
    async_notify(__MODULE__, {:environment_updated, old, new})
    new
  end
  def environment_updated(other, _old),
    do: other

  @doc false
  def log_entry_created({:ok, entry}) do
    async_notify(__MODULE__, {:log_entry_created, entry})
    {:ok, entry}
  end
  def log_entry_created(%LogEntry{} = entry) do
    async_notify(__MODULE__, {:log_entry_created, entry})
    entry
  end
  def log_entry_created(other),
    do: other
end
