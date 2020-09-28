defmodule IpartyWeb.User.RegistrationController do
  use IpartyWeb, :controller

  alias Iparty.Base.{TinyPng, Generator, Bitmoji}
  alias Iparty.{Accounts, Accounts.User}
  alias IpartyWeb.User.Auth

  @sign_up_fail "Sign up failed. If problem persist contact us at iparty.rs@gmail.com"

  def new(conn, _params) do
    changeset = Accounts.change_user_registration(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, user} <- Accounts.register_user(user_params),
         {:ok, _} <- create_user_info(user),
         {:ok, _} <-
           Accounts.deliver_user_confirmation_instructions(
             user,
             &Routes.confirmation_url(conn, :confirm, &1)
           ) do
      conn
      |> put_flash(:info, "You signed up successfully.")
      |> Auth.log_in_user(user)
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)

      _ ->
        conn
        |> put_flash(:error, @sign_up_fail)
        |> redirect(to: "/")
    end
  end

  defp create_user_info(user) do
    gender = Enum.random(["male", "female"])
    name = Generator.gen_name(gender)
    config = %Bitmoji{gender: gender}

    tinypng = config |> Bitmoji.create(:url) |> TinyPng.compress(:url)
    %{body: binary} = tinypng["output"]["url"] |> HTTPoison.get!()

    attrs = %{
      name: name,
      gender: gender,
      bitmoji: Base.encode64(binary, padding: false),
      user_id: user.id
    }

    Accounts.create_user_info(attrs)
  end
end
