# Seeds
alias Iparty.Accounts
alias Iparty.Base.{TinyPng, Generator, Bitmoji}

iparty_params = %{
  email: "iparty.rs@gmail.com",
  password: Application.get_env(:iparty, :google_oauth).password
}

{:ok, user} = Accounts.register_user(iparty_params)

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
