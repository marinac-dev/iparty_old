defmodule Iparty.MixProject do
  use Mix.Project

  def project do
    [
      app: :iparty,
      version: "1.0.0",
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      dialyzer: [plt_file: {"priv/plts/dialyzer.plt"}]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Iparty.Application, []},
      extra_applications: [:logger, :runtime_tools, :os_mon]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.5.3"},
      {:phoenix_ecto, "~> 4.1"},
      {:ecto_sql, "~> 3.4"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_live_view, "~> 0.14.4"},
      # {:phoenix_live_view, github: "phoenixframework/phoenix_live_view", override: true},
      {:floki, ">= 0.0.0", only: :test},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_dashboard, "~> 0.2.0"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:gettext, "~> 0.11"},
      {:plug_cowboy, "~> 2.0"},
      {:jason, "~> 1.0"},
      # JSON Elixir
      {:poison, "~> 4.0"},
      # HTTP requests
      {:httpoison, "~> 1.6"},
      # Password hashing
      {:bcrypt_elixir, "~> 2.0"},
      # HTML spec char parser
      {:html_entities, "~> 0.5.1"},
      # Static security analysis
      # {:sobelow, "~> 0.8", only: :dev}
      # Auth for Phoenix 1.5+
      {:phx_gen_auth, "~> 0.4.0"},
      # Time lib
      {:timex, "~> 3.6"},
      # QR code
      {:eqrcode, "~> 0.1.7"},
      # Code analasys
      {:credo, "~> 1.4", only: :dev},
      # Identicon
      {:egd, github: "erlang/egd"},
      # Typed struct
      {:typed_struct, "~> 0.2.1"},
      # Dialyzer baby :)
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "cmd npm install --prefix assets"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
