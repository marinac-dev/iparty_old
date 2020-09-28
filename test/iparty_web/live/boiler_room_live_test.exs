defmodule IpartyWeb.BoilerRoomLiveTest do
  use IpartyWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Iparty.Accounts

  @create_attrs %{genre: "some genre", name: "some name", slug: "some slug", status: []}
  @update_attrs %{
    genre: "some updated genre",
    name: "some updated name",
    slug: "some updated slug",
    status: []
  }
  @invalid_attrs %{genre: nil, name: nil, slug: nil, status: nil}

  defp fixture(:boiler_room) do
    {:ok, boiler_room} = Accounts.create_boiler_room(@create_attrs)
    boiler_room
  end

  defp create_boiler_room(_) do
    boiler_room = fixture(:boiler_room)
    %{boiler_room: boiler_room}
  end

  describe "Index" do
    setup [:create_boiler_room]

    test "lists all boiler_rooms", %{conn: conn, boiler_room: boiler_room} do
      {:ok, _index_live, html} = live(conn, Routes.boiler_room_index_path(conn, :index))

      assert html =~ "Listing Boiler rooms"
      assert html =~ boiler_room.genre
    end

    test "saves new boiler_room", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.boiler_room_index_path(conn, :index))

      assert index_live |> element("a", "New Boiler room") |> render_click() =~
               "New Boiler room"

      assert_patch(index_live, Routes.boiler_room_index_path(conn, :new))

      assert index_live
             |> form("#boiler_room-form", boiler_room: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#boiler_room-form", boiler_room: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.boiler_room_index_path(conn, :index))

      assert html =~ "Boiler room created successfully"
      assert html =~ "some genre"
    end

    test "updates boiler_room in listing", %{conn: conn, boiler_room: boiler_room} do
      {:ok, index_live, _html} = live(conn, Routes.boiler_room_index_path(conn, :index))

      assert index_live |> element("#boiler_room-#{boiler_room.id} a", "Edit") |> render_click() =~
               "Edit Boiler room"

      assert_patch(index_live, Routes.boiler_room_index_path(conn, :edit, boiler_room))

      assert index_live
             |> form("#boiler_room-form", boiler_room: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#boiler_room-form", boiler_room: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.boiler_room_index_path(conn, :index))

      assert html =~ "Boiler room updated successfully"
      assert html =~ "some updated genre"
    end

    test "deletes boiler_room in listing", %{conn: conn, boiler_room: boiler_room} do
      {:ok, index_live, _html} = live(conn, Routes.boiler_room_index_path(conn, :index))

      assert index_live |> element("#boiler_room-#{boiler_room.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#boiler_room-#{boiler_room.id}")
    end
  end

  describe "Show" do
    setup [:create_boiler_room]

    test "displays boiler_room", %{conn: conn, boiler_room: boiler_room} do
      {:ok, _show_live, html} = live(conn, Routes.boiler_room_show_path(conn, :show, boiler_room))

      assert html =~ "Show Boiler room"
      assert html =~ boiler_room.genre
    end

    test "updates boiler_room within modal", %{conn: conn, boiler_room: boiler_room} do
      {:ok, show_live, _html} = live(conn, Routes.boiler_room_show_path(conn, :show, boiler_room))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Boiler room"

      assert_patch(show_live, Routes.boiler_room_show_path(conn, :edit, boiler_room))

      assert show_live
             |> form("#boiler_room-form", boiler_room: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#boiler_room-form", boiler_room: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.boiler_room_show_path(conn, :show, boiler_room))

      assert html =~ "Boiler room updated successfully"
      assert html =~ "some updated genre"
    end
  end
end
