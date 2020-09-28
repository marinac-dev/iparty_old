defmodule Iparty.Accounts.UserInfo do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_infos" do
    # field :bitmoji, :binary
    field :bitmoji, :string
    field :gender, :string
    field :name, :string
    belongs_to :user, Iparty.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(user_info, attrs) do
    user_info
    |> cast(attrs, [:name, :gender, :bitmoji, :user_id])
    |> validate_required([:name, :gender, :bitmoji, :user_id])
  end
end
