defmodule Iparty.Accounts.Playlist do
  use Ecto.Schema
  import Ecto.Changeset

  schema "playlists" do
    field :content, :string
    field :name, :string
    field :public, :boolean, default: false
    field :tags, :string
    belongs_to :user, Iparty.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(playlist, attrs) do
    playlist
    |> cast(attrs, [:name, :tags, :content, :public, :user_id])
    |> validate_required([:name, :tags, :content, :public, :user_id])
  end
end
