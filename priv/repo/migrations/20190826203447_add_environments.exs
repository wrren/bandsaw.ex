defmodule Bandsaw.Repo.Migrations.AddEnvironments do
  use Ecto.Migration

  def change do
    drop index(:projects, [:name, :environment])
    drop index(:projects, [:key])

    alter table(:projects) do
      remove :environment
      remove :key
    end

    create table(:environments) do
      add :project_id,  references(:projects, on_delete: :delete_all)
      add :name,        :string
      add :key,         :string

      timestamps()
    end
    create unique_index(:environments, [:project_id, :name])

    alter table(:log_entries) do
      remove  :project_id
      add     :environment_id, references(:environments, on_delete: :delete_all)
    end
  end
end
