defmodule IpartyWeb.GoogleOAuthControllerTest do
  use IpartyWeb.ConnCase

  alias Iparty.Accounts

  @create_attrs %{
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

  def fixture(:google_o_auth) do
    {:ok, google_o_auth} = Accounts.create_google_o_auth(@create_attrs)
    google_o_auth
  end

  describe "index" do
    test "lists all google_oauths", %{conn: conn} do
      conn = get(conn, Routes.google_o_auth_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Google oauths"
    end
  end

  describe "new google_o_auth" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.google_o_auth_path(conn, :new))
      assert html_response(conn, 200) =~ "New Google o auth"
    end
  end

  describe "create google_o_auth" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.google_o_auth_path(conn, :create), google_o_auth: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.google_o_auth_path(conn, :show, id)

      conn = get(conn, Routes.google_o_auth_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Google o auth"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.google_o_auth_path(conn, :create), google_o_auth: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Google o auth"
    end
  end

  describe "edit google_o_auth" do
    setup [:create_google_o_auth]

    test "renders form for editing chosen google_o_auth", %{
      conn: conn,
      google_o_auth: google_o_auth
    } do
      conn = get(conn, Routes.google_o_auth_path(conn, :edit, google_o_auth))
      assert html_response(conn, 200) =~ "Edit Google o auth"
    end
  end

  describe "update google_o_auth" do
    setup [:create_google_o_auth]

    test "redirects when data is valid", %{conn: conn, google_o_auth: google_o_auth} do
      conn =
        put(conn, Routes.google_o_auth_path(conn, :update, google_o_auth),
          google_o_auth: @update_attrs
        )

      assert redirected_to(conn) == Routes.google_o_auth_path(conn, :show, google_o_auth)

      conn = get(conn, Routes.google_o_auth_path(conn, :show, google_o_auth))
      assert html_response(conn, 200) =~ "some updated access_token"
    end

    test "renders errors when data is invalid", %{conn: conn, google_o_auth: google_o_auth} do
      conn =
        put(conn, Routes.google_o_auth_path(conn, :update, google_o_auth),
          google_o_auth: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Google o auth"
    end
  end

  describe "delete google_o_auth" do
    setup [:create_google_o_auth]

    test "deletes chosen google_o_auth", %{conn: conn, google_o_auth: google_o_auth} do
      conn = delete(conn, Routes.google_o_auth_path(conn, :delete, google_o_auth))
      assert redirected_to(conn) == Routes.google_o_auth_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.google_o_auth_path(conn, :show, google_o_auth))
      end
    end
  end

  defp create_google_o_auth(_) do
    google_o_auth = fixture(:google_o_auth)
    %{google_o_auth: google_o_auth}
  end
end
