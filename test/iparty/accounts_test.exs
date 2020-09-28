defmodule Iparty.AccountsTest do
  use Iparty.DataCase

  alias Iparty.Accounts
  import Iparty.AccountsFixtures
  alias Iparty.Accounts.{User, UserToken}

  describe "get_user_by_email/1" do
    test "does not return the user if the email does not exist" do
      refute Accounts.get_user_by_email("unknown@example.com")
    end

    test "returns the user if the email exists" do
      %{id: id} = user = user_fixture()
      assert %User{id: ^id} = Accounts.get_user_by_email(user.email)
    end
  end

  describe "get_user_by_email_and_password/1" do
    test "does not return the user if the email does not exist" do
      refute Accounts.get_user_by_email_and_password("unknown@example.com", "hello world!")
    end

    test "does not return the user if the password is not valid" do
      user = user_fixture()
      refute Accounts.get_user_by_email_and_password(user.email, "invalid")
    end

    test "returns the user if the email and password are valid" do
      %{id: id} = user = user_fixture()

      assert %User{id: ^id} =
               Accounts.get_user_by_email_and_password(user.email, valid_user_password())
    end
  end

  describe "get_user!/1" do
    test "raises if id is invalid" do
      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user!(-1)
      end
    end

    test "returns the user with the given id" do
      %{id: id} = user = user_fixture()
      assert %User{id: ^id} = Accounts.get_user!(user.id)
    end
  end

  describe "register_user/1" do
    test "requires email and password to be set" do
      {:error, changeset} = Accounts.register_user(%{})

      assert %{
               password: ["can't be blank"],
               email: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "validates email and password when given" do
      {:error, changeset} = Accounts.register_user(%{email: "not valid", password: "not valid"})

      assert %{
               email: ["must have the @ sign and no spaces"],
               password: ["should be at least 12 character(s)"]
             } = errors_on(changeset)
    end

    test "validates maximum values for e-mail and password for security" do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Accounts.register_user(%{email: too_long, password: too_long})
      assert "should be at most 160 character(s)" in errors_on(changeset).email
      assert "should be at most 80 character(s)" in errors_on(changeset).password
    end

    test "validates e-mail uniqueness" do
      %{email: email} = user_fixture()
      {:error, changeset} = Accounts.register_user(%{email: email})
      assert "has already been taken" in errors_on(changeset).email

      # Now try with the upper cased e-mail too, to check that email case is ignored.
      {:error, changeset} = Accounts.register_user(%{email: String.upcase(email)})
      assert "has already been taken" in errors_on(changeset).email
    end

    test "registers users with a hashed password" do
      email = unique_user_email()
      {:ok, user} = Accounts.register_user(%{email: email, password: valid_user_password()})
      assert user.email == email
      assert is_binary(user.hashed_password)
      assert is_nil(user.confirmed_at)
      assert is_nil(user.password)
    end
  end

  describe "change_user_registration/2" do
    test "returns a changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_user_registration(%User{})
      assert changeset.required == [:password, :email]
    end
  end

  describe "change_user_email/2" do
    test "returns a user changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_user_email(%User{})
      assert changeset.required == [:email]
    end
  end

  describe "apply_user_email/3" do
    setup do
      %{user: user_fixture()}
    end

    test "requires email to change", %{user: user} do
      {:error, changeset} = Accounts.apply_user_email(user, valid_user_password(), %{})
      assert %{email: ["did not change"]} = errors_on(changeset)
    end

    test "validates email", %{user: user} do
      {:error, changeset} =
        Accounts.apply_user_email(user, valid_user_password(), %{email: "not valid"})

      assert %{email: ["must have the @ sign and no spaces"]} = errors_on(changeset)
    end

    test "validates maximum value for e-mail for security", %{user: user} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Accounts.apply_user_email(user, valid_user_password(), %{email: too_long})

      assert "should be at most 160 character(s)" in errors_on(changeset).email
    end

    test "validates e-mail uniqueness", %{user: user} do
      %{email: email} = user_fixture()

      {:error, changeset} =
        Accounts.apply_user_email(user, valid_user_password(), %{email: email})

      assert "has already been taken" in errors_on(changeset).email
    end

    test "validates current password", %{user: user} do
      {:error, changeset} =
        Accounts.apply_user_email(user, "invalid", %{email: unique_user_email()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "applies the e-mail without persisting it", %{user: user} do
      email = unique_user_email()
      {:ok, user} = Accounts.apply_user_email(user, valid_user_password(), %{email: email})
      assert user.email == email
      assert Accounts.get_user!(user.id).email != email
    end
  end

  describe "deliver_update_email_instructions/3" do
    setup do
      %{user: user_fixture()}
    end

    test "sends token through notification", %{user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_update_email_instructions(user, "current@example.com", url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert user_token = Repo.get_by(UserToken, token: :crypto.hash(:sha256, token))
      assert user_token.user_id == user.id
      assert user_token.sent_to == user.email
      assert user_token.context == "change:current@example.com"
    end
  end

  describe "update_user_email/2" do
    setup do
      user = user_fixture()
      email = unique_user_email()

      token =
        extract_user_token(fn url ->
          Accounts.deliver_update_email_instructions(%{user | email: email}, user.email, url)
        end)

      %{user: user, token: token, email: email}
    end

    test "updates the e-mail with a valid token", %{user: user, token: token, email: email} do
      assert Accounts.update_user_email(user, token) == :ok
      changed_user = Repo.get!(User, user.id)
      assert changed_user.email != user.email
      assert changed_user.email == email
      assert changed_user.confirmed_at
      assert changed_user.confirmed_at != user.confirmed_at
      refute Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not update e-mail with invalid token", %{user: user} do
      assert Accounts.update_user_email(user, "oops") == :error
      assert Repo.get!(User, user.id).email == user.email
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not update e-mail if user e-mail changed", %{user: user, token: token} do
      assert Accounts.update_user_email(%{user | email: "current@example.com"}, token) == :error
      assert Repo.get!(User, user.id).email == user.email
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not update e-mail if token expired", %{user: user, token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Accounts.update_user_email(user, token) == :error
      assert Repo.get!(User, user.id).email == user.email
      assert Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "change_user_password/2" do
    test "returns a user changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_user_password(%User{})
      assert changeset.required == [:password]
    end
  end

  describe "update_user_password/3" do
    setup do
      %{user: user_fixture()}
    end

    test "validates password", %{user: user} do
      {:error, changeset} =
        Accounts.update_user_password(user, valid_user_password(), %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{user: user} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Accounts.update_user_password(user, valid_user_password(), %{password: too_long})

      assert "should be at most 80 character(s)" in errors_on(changeset).password
    end

    test "validates current password", %{user: user} do
      {:error, changeset} =
        Accounts.update_user_password(user, "invalid", %{password: valid_user_password()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "updates the password", %{user: user} do
      {:ok, user} =
        Accounts.update_user_password(user, valid_user_password(), %{
          password: "new valid password"
        })

      assert is_nil(user.password)
      assert Accounts.get_user_by_email_and_password(user.email, "new valid password")
    end

    test "deletes all tokens for the given user", %{user: user} do
      _ = Accounts.generate_user_session_token(user)

      {:ok, _} =
        Accounts.update_user_password(user, valid_user_password(), %{
          password: "new valid password"
        })

      refute Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "generate_user_session_token/1" do
    setup do
      %{user: user_fixture()}
    end

    test "generates a token", %{user: user} do
      token = Accounts.generate_user_session_token(user)
      assert user_token = Repo.get_by(UserToken, token: token)
      assert user_token.context == "session"

      # Creating the same token for another user should fail
      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%UserToken{
          token: user_token.token,
          user_id: user_fixture().id,
          context: "session"
        })
      end
    end
  end

  describe "get_user_by_session_token/1" do
    setup do
      user = user_fixture()
      token = Accounts.generate_user_session_token(user)
      %{user: user, token: token}
    end

    test "returns user by token", %{user: user, token: token} do
      assert session_user = Accounts.get_user_by_session_token(token)
      assert session_user.id == user.id
    end

    test "does not return user for invalid token" do
      refute Accounts.get_user_by_session_token("oops")
    end

    test "does not return user for expired token", %{token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Accounts.get_user_by_session_token(token)
    end
  end

  describe "delete_session_token/1" do
    test "deletes the token" do
      user = user_fixture()
      token = Accounts.generate_user_session_token(user)
      assert Accounts.delete_session_token(token) == :ok
      refute Accounts.get_user_by_session_token(token)
    end
  end

  describe "deliver_user_confirmation_instructions/2" do
    setup do
      %{user: user_fixture()}
    end

    test "sends token through notification", %{user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_confirmation_instructions(user, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert user_token = Repo.get_by(UserToken, token: :crypto.hash(:sha256, token))
      assert user_token.user_id == user.id
      assert user_token.sent_to == user.email
      assert user_token.context == "confirm"
    end
  end

  describe "confirm_user/2" do
    setup do
      user = user_fixture()

      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_confirmation_instructions(user, url)
        end)

      %{user: user, token: token}
    end

    test "confirms the e-mail with a valid token", %{user: user, token: token} do
      assert {:ok, confirmed_user} = Accounts.confirm_user(token)
      assert confirmed_user.confirmed_at
      assert confirmed_user.confirmed_at != user.confirmed_at
      assert Repo.get!(User, user.id).confirmed_at
      refute Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not confirm with invalid token", %{user: user} do
      assert Accounts.confirm_user("oops") == :error
      refute Repo.get!(User, user.id).confirmed_at
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not confirm e-mail if token expired", %{user: user, token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Accounts.confirm_user(token) == :error
      refute Repo.get!(User, user.id).confirmed_at
      assert Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "deliver_user_reset_password_instructions/2" do
    setup do
      %{user: user_fixture()}
    end

    test "sends token through notification", %{user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_reset_password_instructions(user, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert user_token = Repo.get_by(UserToken, token: :crypto.hash(:sha256, token))
      assert user_token.user_id == user.id
      assert user_token.sent_to == user.email
      assert user_token.context == "reset_password"
    end
  end

  describe "get_user_by_reset_password_token/2" do
    setup do
      user = user_fixture()

      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_reset_password_instructions(user, url)
        end)

      %{user: user, token: token}
    end

    test "returns the user with valid token", %{user: %{id: id}, token: token} do
      assert %User{id: ^id} = Accounts.get_user_by_reset_password_token(token)
      assert Repo.get_by(UserToken, user_id: id)
    end

    test "does not return the user with invalid token", %{user: user} do
      refute Accounts.get_user_by_reset_password_token("oops")
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not return the user if token expired", %{user: user, token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Accounts.get_user_by_reset_password_token(token)
      assert Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "reset_user_password/3" do
    setup do
      %{user: user_fixture()}
    end

    test "validates password", %{user: user} do
      {:error, changeset} =
        Accounts.reset_user_password(user, %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{user: user} do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Accounts.reset_user_password(user, %{password: too_long})
      assert "should be at most 80 character(s)" in errors_on(changeset).password
    end

    test "updates the password", %{user: user} do
      {:ok, updated_user} = Accounts.reset_user_password(user, %{password: "new valid password"})
      assert is_nil(updated_user.password)
      assert Accounts.get_user_by_email_and_password(user.email, "new valid password")
    end

    test "deletes all tokens for the given user", %{user: user} do
      _ = Accounts.generate_user_session_token(user)
      {:ok, _} = Accounts.reset_user_password(user, %{password: "new valid password"})
      refute Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "inspect/2" do
    test "does not include password" do
      refute inspect(%User{password: "123456"}) =~ "password: \"123456\""
    end
  end

  describe "boiler_rooms" do
    alias Iparty.Accounts.BoilerRoom

    @valid_attrs %{genre: "some genre", name: "some name", slug: "some slug", status: []}
    @update_attrs %{
      genre: "some updated genre",
      name: "some updated name",
      slug: "some updated slug",
      status: []
    }
    @invalid_attrs %{genre: nil, name: nil, slug: nil, status: nil}

    def boiler_room_fixture(attrs \\ %{}) do
      {:ok, boiler_room} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_boiler_room()

      boiler_room
    end

    test "list_boiler_rooms/0 returns all boiler_rooms" do
      boiler_room = boiler_room_fixture()
      assert Accounts.list_boiler_rooms() == [boiler_room]
    end

    test "get_boiler_room!/1 returns the boiler_room with given id" do
      boiler_room = boiler_room_fixture()
      assert Accounts.get_boiler_room!(boiler_room.id) == boiler_room
    end

    test "create_boiler_room/1 with valid data creates a boiler_room" do
      assert {:ok, %BoilerRoom{} = boiler_room} = Accounts.create_boiler_room(@valid_attrs)
      assert boiler_room.genre == "some genre"
      assert boiler_room.name == "some name"
      assert boiler_room.slug == "some slug"
      assert boiler_room.status == []
    end

    test "create_boiler_room/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_boiler_room(@invalid_attrs)
    end

    test "update_boiler_room/2 with valid data updates the boiler_room" do
      boiler_room = boiler_room_fixture()

      assert {:ok, %BoilerRoom{} = boiler_room} =
               Accounts.update_boiler_room(boiler_room, @update_attrs)

      assert boiler_room.genre == "some updated genre"
      assert boiler_room.name == "some updated name"
      assert boiler_room.slug == "some updated slug"
      assert boiler_room.status == []
    end

    test "update_boiler_room/2 with invalid data returns error changeset" do
      boiler_room = boiler_room_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Accounts.update_boiler_room(boiler_room, @invalid_attrs)

      assert boiler_room == Accounts.get_boiler_room!(boiler_room.id)
    end

    test "delete_boiler_room/1 deletes the boiler_room" do
      boiler_room = boiler_room_fixture()
      assert {:ok, %BoilerRoom{}} = Accounts.delete_boiler_room(boiler_room)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_boiler_room!(boiler_room.id) end
    end

    test "change_boiler_room/1 returns a boiler_room changeset" do
      boiler_room = boiler_room_fixture()
      assert %Ecto.Changeset{} = Accounts.change_boiler_room(boiler_room)
    end
  end

  describe "google_oauths" do
    alias Iparty.Accounts.GoogleOAuth

    @valid_attrs %{
      access_token: "some access_token",
      expire_at: ~N[2010-04-17 14:00:00],
      json_data: "some json_data",
      refresh_token: "some refresh_token"
    }
    @update_attrs %{
      access_token: "some updated access_token",
      expire_at: ~N[2011-05-18 15:01:01],
      json_data: "some updated json_data",
      refresh_token: "some updated refresh_token"
    }
    @invalid_attrs %{access_token: nil, expire_at: nil, json_data: nil, refresh_token: nil}

    def google_o_auth_fixture(attrs \\ %{}) do
      {:ok, google_o_auth} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_google_o_auth()

      google_o_auth
    end

    test "list_google_oauths/0 returns all google_oauths" do
      google_o_auth = google_o_auth_fixture()
      assert Accounts.list_google_oauths() == [google_o_auth]
    end

    test "get_google_o_auth!/1 returns the google_o_auth with given id" do
      google_o_auth = google_o_auth_fixture()
      assert Accounts.get_google_o_auth!(google_o_auth.id) == google_o_auth
    end

    test "create_google_o_auth/1 with valid data creates a google_o_auth" do
      assert {:ok, %GoogleOAuth{} = google_o_auth} = Accounts.create_google_o_auth(@valid_attrs)
      assert google_o_auth.access_token == "some access_token"
      assert google_o_auth.expire_at == ~N[2010-04-17 14:00:00]
      assert google_o_auth.json_data == "some json_data"
      assert google_o_auth.refresh_token == "some refresh_token"
    end

    test "create_google_o_auth/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_google_o_auth(@invalid_attrs)
    end

    test "update_google_o_auth/2 with valid data updates the google_o_auth" do
      google_o_auth = google_o_auth_fixture()

      assert {:ok, %GoogleOAuth{} = google_o_auth} =
               Accounts.update_google_o_auth(google_o_auth, @update_attrs)

      assert google_o_auth.access_token == "some updated access_token"
      assert google_o_auth.expire_at == ~N[2011-05-18 15:01:01]
      assert google_o_auth.json_data == "some updated json_data"
      assert google_o_auth.refresh_token == "some updated refresh_token"
    end

    test "update_google_o_auth/2 with invalid data returns error changeset" do
      google_o_auth = google_o_auth_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Accounts.update_google_o_auth(google_o_auth, @invalid_attrs)

      assert google_o_auth == Accounts.get_google_o_auth!(google_o_auth.id)
    end

    test "delete_google_o_auth/1 deletes the google_o_auth" do
      google_o_auth = google_o_auth_fixture()
      assert {:ok, %GoogleOAuth{}} = Accounts.delete_google_o_auth(google_o_auth)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_google_o_auth!(google_o_auth.id) end
    end

    test "change_google_o_auth/1 returns a google_o_auth changeset" do
      google_o_auth = google_o_auth_fixture()
      assert %Ecto.Changeset{} = Accounts.change_google_o_auth(google_o_auth)
    end
  end

  describe "user_infos" do
    alias Iparty.Accounts.UserInfo

    @valid_attrs %{bitmoji: "some bitmoji", gender: "some gender", name: "some name"}
    @update_attrs %{
      bitmoji: "some updated bitmoji",
      gender: "some updated gender",
      name: "some updated name"
    }
    @invalid_attrs %{bitmoji: nil, gender: nil, name: nil}

    def user_info_fixture(attrs \\ %{}) do
      {:ok, user_info} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user_info()

      user_info
    end

    test "list_user_infos/0 returns all user_infos" do
      user_info = user_info_fixture()
      assert Accounts.list_user_infos() == [user_info]
    end

    test "get_user_info!/1 returns the user_info with given id" do
      user_info = user_info_fixture()
      assert Accounts.get_user_info!(user_info.id) == user_info
    end

    test "create_user_info/1 with valid data creates a user_info" do
      assert {:ok, %UserInfo{} = user_info} = Accounts.create_user_info(@valid_attrs)
      assert user_info.bitmoji == "some bitmoji"
      assert user_info.gender == "some gender"
      assert user_info.name == "some name"
    end

    test "create_user_info/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user_info(@invalid_attrs)
    end

    test "update_user_info/2 with valid data updates the user_info" do
      user_info = user_info_fixture()
      assert {:ok, %UserInfo{} = user_info} = Accounts.update_user_info(user_info, @update_attrs)
      assert user_info.bitmoji == "some updated bitmoji"
      assert user_info.gender == "some updated gender"
      assert user_info.name == "some updated name"
    end

    test "update_user_info/2 with invalid data returns error changeset" do
      user_info = user_info_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user_info(user_info, @invalid_attrs)
      assert user_info == Accounts.get_user_info!(user_info.id)
    end

    test "delete_user_info/1 deletes the user_info" do
      user_info = user_info_fixture()
      assert {:ok, %UserInfo{}} = Accounts.delete_user_info(user_info)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user_info!(user_info.id) end
    end

    test "change_user_info/1 returns a user_info changeset" do
      user_info = user_info_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user_info(user_info)
    end
  end

  describe "playlists" do
    alias Iparty.Accounts.Playlist

    @valid_attrs %{content: "some content", name: "some name", public: true, tags: "some tags"}
    @update_attrs %{content: "some updated content", name: "some updated name", public: false, tags: "some updated tags"}
    @invalid_attrs %{content: nil, name: nil, public: nil, tags: nil}

    def playlist_fixture(attrs \\ %{}) do
      {:ok, playlist} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_playlist()

      playlist
    end

    test "list_playlists/0 returns all playlists" do
      playlist = playlist_fixture()
      assert Accounts.list_playlists() == [playlist]
    end

    test "get_playlist!/1 returns the playlist with given id" do
      playlist = playlist_fixture()
      assert Accounts.get_playlist!(playlist.id) == playlist
    end

    test "create_playlist/1 with valid data creates a playlist" do
      assert {:ok, %Playlist{} = playlist} = Accounts.create_playlist(@valid_attrs)
      assert playlist.content == "some content"
      assert playlist.name == "some name"
      assert playlist.public == true
      assert playlist.tags == "some tags"
    end

    test "create_playlist/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_playlist(@invalid_attrs)
    end

    test "update_playlist/2 with valid data updates the playlist" do
      playlist = playlist_fixture()
      assert {:ok, %Playlist{} = playlist} = Accounts.update_playlist(playlist, @update_attrs)
      assert playlist.content == "some updated content"
      assert playlist.name == "some updated name"
      assert playlist.public == false
      assert playlist.tags == "some updated tags"
    end

    test "update_playlist/2 with invalid data returns error changeset" do
      playlist = playlist_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_playlist(playlist, @invalid_attrs)
      assert playlist == Accounts.get_playlist!(playlist.id)
    end

    test "delete_playlist/1 deletes the playlist" do
      playlist = playlist_fixture()
      assert {:ok, %Playlist{}} = Accounts.delete_playlist(playlist)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_playlist!(playlist.id) end
    end

    test "change_playlist/1 returns a playlist changeset" do
      playlist = playlist_fixture()
      assert %Ecto.Changeset{} = Accounts.change_playlist(playlist)
    end
  end
end
