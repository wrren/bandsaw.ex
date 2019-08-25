defmodule Bandsaw.Repo.Migrations.AddBaseTables do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :name,        :string
      add :key,         :string
      add :environment, :integer, null: false, default: 0

      timestamps()
    end
    create unique_index(:projects, [:name, :environment])
    create unique_index(:projects, [:key])

    create table(:log_entries) do
      add :project_id,  references(:projects, on_delete: :delete_all)

      add :level,       :integer
      add :timestamp,   :utc_datetime
      add :message,     :text
    end
  end
end
