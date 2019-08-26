defmodule Bandsaw do
  @moduledoc """
  Bandsaw keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  alias Bandsaw.{
    Project,
    Environment,
    LogEntry
  }

  @doc """
  List all Project records that satisfy the given query constraints
  """
  defdelegate list_projects(),
    to: Project, as: :list
  defdelegate list_projects(opts),
    to: Project, as: :list

  @doc """
  Get a Project record that satisfies the given query constraints
  """
  defdelegate get_project(opts),
    to: Project, as: :one

  @doc """
  Create a new Project record
  """
  defdelegate create_project(params),
    to: Project, as: :create

  @doc """
  Update a Project record
  """
  defdelegate update_project(project, params),
    to: Project, as: :update

  @doc """
  Delete a Project
  """
  defdelegate delete_project(project),
    to: Project, as: :delete

  @doc """
  List all Environment records that satisfy the given query constraints
  """
  defdelegate list_environments(),
    to: Environment, as: :list
  defdelegate list_environments(opts),
    to: Environment, as: :list

  @doc """
  Get an Environment that satisfies the given query constraints
  """
  defdelegate get_environment(opts),
    to: Environment, as: :one

  @doc """
  Create a new Environment record
  """
  defdelegate create_environment(params),
    to: Environment, as: :create

  @doc """
  Update an Environment record
  """
  defdelegate update_environment(environment, params),
    to: Environment, as: :update

  @doc """
  Delete a Environment
  """
  defdelegate delete_environment(environment),
    to: Environment, as: :delete

  @doc """
  List all LogEntry records that satisfy the given query constraints
  """
  defdelegate list_log_entriess(),
    to: LogEntry, as: :list
  defdelegate list_log_entriess(opts),
    to: LogEntry, as: :list

  @doc """
  Get an LogEntry that satisfies the given query constraints
  """
  defdelegate get_log_entry(opts),
    to: LogEntry, as: :one

  @doc """
  Create a new LogEntry record
  """
  defdelegate create_log_entry(params),
    to: LogEntry, as: :create

  @doc """
  Update an LogEntry record
  """
  defdelegate update_log_entry(log_entry, params),
    to: LogEntry, as: :update

  @doc """
  Delete a LogEntry
  """
  defdelegate delete_log_entry(log_entry),
    to: LogEntry, as: :delete
end
