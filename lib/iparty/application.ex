defmodule Iparty.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Iparty.Repo,
      # Start the Telemetry supervisor
      IpartyWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Iparty.PubSub},
      # Start the Endpoint (http/https)
      IpartyWeb.Endpoint,
      # Start a worker by calling: Iparty.Worker.start_link(arg)
      # {Iparty.Worker, arg}
      # My Presence :)
      Iparty.BoilerRoomPresence,
      # My KV storage
      Iparty.Base.KVStorage
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html for other strategies and supported options
    opts = [strategy: :one_for_one, name: Iparty.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    IpartyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
