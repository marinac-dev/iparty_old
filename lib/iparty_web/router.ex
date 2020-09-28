defmodule IpartyWeb.Router do
  use IpartyWeb, :router

  import IpartyWeb.User.Auth

  # @csp "default-src 'self'; script-src 'self' 'unsafe-eval'; style-src 'self' 'unsafe-inline' 'unsafe-eval'; connect-src ws://localhost:4000/"
  # @csp "default-src 'self'; img-src https://www.iparty.rs/ http://localhost:4000"

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {IpartyWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
    # plug :put_secure_browser_headers, %{"content-security-policy" => @csp}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", IpartyWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/iparty", PageController, :iparty
    get "/how-to-iparty", PageController, :how_to
    get "/boiler-room", BoilerRoomController, :index
    get "/boiler-room/:slug", BoilerRoomController, :show

    # More
    get "/tos", PageController, :tos
    get "/faq", PageController, :faq
    get "/about", PageController, :about
    get "/contact", PageController, :contact
    get "/privacy-policy", PageController, :privacy
  end

  ## Authentication routes

  scope "/", IpartyWeb do
    pipe_through [:browser]

    delete "/sign-out", User.SessionController, :delete
    get "/confirm-user", User.ConfirmationController, :new
    post "/confirm-user", User.ConfirmationController, :create
    get "/confirm-user/:token", User.ConfirmationController, :confirm
  end

  scope "/", IpartyWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    # Sign in|up
    get "/sign-up", User.RegistrationController, :new
    post "/sign-up", User.RegistrationController, :create
    get "/sign-in", User.SessionController, :new
    post "/sign-in", User.SessionController, :create

    # Reset password
    get "/reset-password", User.ResetPasswordController, :new
    post "/reset-password", User.ResetPasswordController, :create
    get "/reset-password/:token", User.ResetPasswordController, :edit
    put "/reset-password/:token", User.ResetPasswordController, :update
  end

  scope "/", IpartyWeb do
    pipe_through [:browser, :require_authenticated_user]

    # Profile
    get "/profile", PageController, :profile

    # Settings
    get "/settings", User.SettingsController, :edit
    put "/settings/update_password", User.SettingsController, :update_password
    put "/settings/update_email", User.SettingsController, :update_email
    get "/settings/confirm_email/:token", User.SettingsController, :confirm_email

    # Boiler room
    get "/your-rooms", BoilerRoomController, :user_index
    get "/boiler-room/create/new", BoilerRoomController, :new

    # Google OAuth
    get "/auth/google", GoogleOAuthController, :google_request
    get "/auth/google/callback", GoogleOAuthController, :google_callback

    # Playlists
    live "/playlists", PlaylistLive.Index, :index
    live "/playlists/new", PlaylistLive.Index, :new
    live "/playlists/:id/edit", PlaylistLive.Index, :edit

    live "/playlists/:id", PlaylistLive.Show, :show
    live "/playlists/:id/show/edit", PlaylistLive.Show, :edit
  end

  # Admin panel
  import Plug.BasicAuth

  pipeline :admin do
    plug :basic_auth, Application.compile_env(:iparty, :live_dashboard)
  end

  scope "/admin/" do
    pipe_through [:browser, :admin]

    import Phoenix.LiveDashboard.Router
    live_dashboard "/dashboard", metrics: IpartyWeb.Telemetry
  end
end
