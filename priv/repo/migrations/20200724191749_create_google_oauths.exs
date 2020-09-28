defmodule Iparty.Repo.Migrations.CreateGoogleOauths do
  use Ecto.Migration

  def change do
    create table(:google_oauths) do
      add :access_token, :text
      add :refresh_token, :text
      add :expire_at, :naive_datetime
      add :json_data, :text
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:google_oauths, [:user_id])
  end
end
