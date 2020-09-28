defmodule Iparty.Repo.Migrations.CreateUserInfos do
  use Ecto.Migration

  def change do
    create table(:user_infos) do
      add :name, :string
      add :gender, :string
      # add :bitmoji, :binary
      add :bitmoji, :text
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:user_infos, [:user_id])
  end
end
