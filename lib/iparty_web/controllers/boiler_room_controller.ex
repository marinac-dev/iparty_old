defmodule IpartyWeb.BoilerRoomController do
  use IpartyWeb, :controller
  alias Iparty.Accounts

  def index(conn, _params),
    do: conn |> render("index.html")

  def new(conn, _params),
    do: conn |> render("new.html")

  def user_index(conn, _params) do
    rooms = Accounts.list_boiler_rooms_user(conn.assigns.current_user.id)
    conn |> render("index.html", rooms: rooms)
  end

  def show(conn, %{"slug" => slug}),
    do: handle_room(conn, Accounts.get_boiler_room(slug, :slug))

  defp handle_room(conn, nil),
    do: conn |> send_resp(404, "")

  defp handle_room(conn, %Accounts.BoilerRoom{} = room),
    do: handle_room_online(conn, room)

  defp handle_room_online(conn, %{online: true} = room),
    do: conn |> render("show.html", room: Iparty.Repo.preload(room, :user))

  defp handle_room_online(conn, %{online: false} = room),
    do: handle_room_offline(conn, room)

  defp handle_room_offline(
         %{assigns: %{current_user: %{id: id}}} = conn,
         %{user_id: user_id} = room
       )
       when id == user_id,
       do: conn |> render("show.html", room: Iparty.Repo.preload(room, :user))

  defp handle_room_offline(conn, _room),
    do:
      conn
      |> put_flash(:error, "Room offline.")
      |> redirect(to: Routes.boiler_room_path(conn, :index))
end
