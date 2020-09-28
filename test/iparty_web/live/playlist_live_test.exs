defmodule IpartyWeb.PlaylistLiveTest do
  use IpartyWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Iparty.Accounts

  @create_attrs %{content: "some content", name: "some name", public: true, tags: "some tags"}
  @update_attrs %{content: "some updated content", name: "some updated name", public: false, tags: "some updated tags"}
  @invalid_attrs %{content: nil, name: nil, public: nil, tags: nil}

  defp fixture(:playlist) do
    {:ok, playlist} = Accounts.create_playlist(@create_attrs)
    playlist
  end

  defp create_playlist(_) do
    playlist = fixture(:playlist)
    %{playlist: playlist}
  end

  describe "Index" do
    setup [:create_playlist]

    test "lists all playlists", %{conn: conn, playlist: playlist} do
      {:ok, _index_live, html} = live(conn, Routes.playlist_index_path(conn, :index))

      assert html =~ "Listing Playlists"
      assert html =~ playlist.content
    end

    test "saves new playlist", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.playlist_index_path(conn, :index))

      assert index_live |> element("a", "New Playlist") |> render_click() =~
               "New Playlist"

      assert_patch(index_live, Routes.playlist_index_path(conn, :new))

      assert index_live
             |> form("#playlist-form", playlist: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#playlist-form", playlist: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.playlist_index_path(conn, :index))

      assert html =~ "Playlist created successfully"
      assert html =~ "some content"
    end

    test "updates playlist in listing", %{conn: conn, playlist: playlist} do
      {:ok, index_live, _html} = live(conn, Routes.playlist_index_path(conn, :index))

      assert index_live |> element("#playlist-#{playlist.id} a", "Edit") |> render_click() =~
               "Edit Playlist"

      assert_patch(index_live, Routes.playlist_index_path(conn, :edit, playlist))

      assert index_live
             |> form("#playlist-form", playlist: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#playlist-form", playlist: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.playlist_index_path(conn, :index))

      assert html =~ "Playlist updated successfully"
      assert html =~ "some updated content"
    end

    test "deletes playlist in listing", %{conn: conn, playlist: playlist} do
      {:ok, index_live, _html} = live(conn, Routes.playlist_index_path(conn, :index))

      assert index_live |> element("#playlist-#{playlist.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#playlist-#{playlist.id}")
    end
  end

  describe "Show" do
    setup [:create_playlist]

    test "displays playlist", %{conn: conn, playlist: playlist} do
      {:ok, _show_live, html} = live(conn, Routes.playlist_show_path(conn, :show, playlist))

      assert html =~ "Show Playlist"
      assert html =~ playlist.content
    end

    test "updates playlist within modal", %{conn: conn, playlist: playlist} do
      {:ok, show_live, _html} = live(conn, Routes.playlist_show_path(conn, :show, playlist))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Playlist"

      assert_patch(show_live, Routes.playlist_show_path(conn, :edit, playlist))

      assert show_live
             |> form("#playlist-form", playlist: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#playlist-form", playlist: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.playlist_show_path(conn, :show, playlist))

      assert html =~ "Playlist updated successfully"
      assert html =~ "some updated content"
    end
  end
end
