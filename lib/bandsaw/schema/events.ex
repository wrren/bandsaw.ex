defmodule Bandsaw.Events do
  use Event.Source, name: __MODULE__, max_events: 1_000

  @doc false
  def project_created({:ok, project}) do
    async_notify(__MODULE__, {:project_created, project})
    {:ok, project}
  end
  def project_create(other),
    do: other

  @doc false
  def project_updated(old, {:ok, new}) do
    async_notify(__MODULE__, {:project_updated, old, new})
    {:ok, new}
  end
  def project_updated(_old, other),
    do: other

  @doc false
  def log_entry_created({:ok, entry}) do
    async_notify(__MODULE__, {:log_entry_created, entry})
    {:ok, entry}
  end
  def log_entry_created(other),
    do: other
end
