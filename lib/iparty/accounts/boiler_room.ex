defmodule Iparty.Accounts.BoilerRoom do
  use Ecto.Schema
  import Ecto.Changeset

  schema "boiler_rooms" do
    field :genre, :string
    field :name, :string
    field :slug, :string
    field :status, :string
    field :views, :integer
    field :online, :boolean
    belongs_to :user, Iparty.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(boiler_room, attrs \\ %{}) do
    boiler_room
    |> cast(attrs, [:name, :genre, :slug, :status, :user_id, :online, :views])
    |> validate_required([:name, :genre, :slug, :status, :user_id, :online, :views])
    |> unique_constraint(:slug)
    |> validate_length(:name, min: 3, max: 30)
    |> validate_length(:slug, min: 2, max: 40)
    |> validate_length(:genre, min: 2, max: 60)
    |> validate_format(:name, ~r/^[\w\d\s]+$/)
    |> validate_format(:slug, ~r/^[a-z\_\-]+$/)
    |> validate_format(:genre, ~r/^[\w\d\,\s]+$/)
    |> validate_inclusion(:status, ~w(public private invite))
  end
end
