defmodule Iparty.Repo.Migrations.CreateBoilerRooms do
  use Ecto.Migration

  def change do
    create table(:boiler_rooms) do
      add :name, :string, null: false
      add :genre, :string, null: false
      add :slug, :string, null: false
      add :views, :integer, null: false, default: 0
      add :online, :boolean, null: false, default: false
      add :status, :string, null: false, default: "public"
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:boiler_rooms, [:slug])
    create index(:boiler_rooms, [:user_id])
  end
end
