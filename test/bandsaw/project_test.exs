defmodule Bandsaw.ProjectTest do
  use Bandsaw.DataCase
  import Bandsaw.Fixtures
  alias Bandsaw.Project

  @valid_params %{name: random_string()}

  describe "changeset/2" do
    test "produces an invalid changeset when no name is provided" do
      refute Project.changeset(%Project{}, %{}).valid?
    end

    test "produces a valid changeset when a name is provided" do
      assert Project.changeset(%Project{}, @valid_params).valid?
    end
  end
end
