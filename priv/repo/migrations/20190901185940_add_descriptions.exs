defmodule Bandsaw.Repo.Migrations.AddDescriptions do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add :description, :text
    end

    alter table(:environments) do
      add :description, :text
    end
  end
end
