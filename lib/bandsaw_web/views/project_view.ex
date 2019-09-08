defmodule Bandsaw.Web.ProjectView do
  use Bandsaw.Web, :view

  @doc """
  Generate the CSS classnames for a given project card
  """
  def card_class(%{is_deleting?: true}),
    do: "uk-card uk-card-secondary"
  def card_class(_),
    do: "uk-card uk-card-primary"
end
