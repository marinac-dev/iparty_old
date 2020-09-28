defmodule Iparty.Base.Expired do
  alias Iparty.Base.Google

  def google(nil) do
    user = Iparty.Repo.get_by!(Iparty.Accounts.User, email: "iparty.rs@gmail.com")
    token = Iparty.Accounts.get_google_o_auth(user.id, :user)

    case token do
      nil ->
        {:ok, nil}

      token ->
        google(token)
    end
  end

  def google(%{expire_at: expire} = token) do
    now = DateTime.utc_now() |> DateTime.truncate(:second) |> DateTime.to_naive()

    if expire > now do
      {:ok, token}
    else
      Google.refresh_token(token)
    end
  end
end
