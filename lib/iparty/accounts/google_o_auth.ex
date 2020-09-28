defmodule Iparty.Accounts.GoogleOAuth do
  use Ecto.Schema
  import Ecto.Changeset

  schema "google_oauths" do
    field :access_token, :string
    field :expire_at, :naive_datetime
    field :json_data, :string
    field :refresh_token, :string
    belongs_to :user, Iparty.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(google_o_auth, attrs) do
    google_o_auth
    |> cast(attrs, [:access_token, :refresh_token, :expire_at, :json_data, :user_id])
    |> validate_required([:access_token, :refresh_token, :expire_at, :json_data, :user_id])
  end
end
