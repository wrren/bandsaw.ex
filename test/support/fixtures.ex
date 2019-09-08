defmodule Bandsaw.Fixtures do

  @random_level Enum.random([:debug, :info, :warn, :error])

  def create_project,
    do: Bandsaw.create_project!(%{name: random_string()})
  def create_project(%{}),
    do: {:ok, project: create_project()}

  def create_environment,
    do: Bandsaw.create_environment(%{name: random_string()})
  def create_environment(%Bandsaw.Project{id: id}),
    do: Bandsaw.create_environment!(%{name: random_string(), project_id: id})
  def create_environment(%{project: project}),
    do: {:ok, environment: create_environment(project)}
  def create_environment(%{}),
    do: {:ok, environment: create_environment()}

  def create_log_entry,
    do: Bandsaw.create_log_entry!(%{level: @random_level, message: random_string(), timestamp: DateTime.utc_now()})
  def create_log_entry(%Bandsaw.Environment{id: id}),
    do: Bandsaw.create_log_entry!(%{level: @random_level, message: random_string(), timestamp: DateTime.utc_now(), environment_id: id})
  def create_log_entry(%{environment: environment, entries: entries}),
    do: {:ok, entries: [create_log_entry(environment) | entries]}
  def create_log_entry(%{environment: environment}),
    do: {:ok, entries: [create_log_entry(environment)]}

  #
  # Generate a random string of the given length that's URL-encodeable
  #
  def random_string(length \\ 16) do
    length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64()
  end
end
