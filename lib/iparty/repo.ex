defmodule Iparty.Repo do
  use Ecto.Repo,
    otp_app: :iparty,
    adapter: Ecto.Adapters.Postgres
end
