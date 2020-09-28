defmodule IpartyWeb.Live.View.NewRoom do
  use IpartyWeb, :live_view
  alias Iparty.{Accounts, Accounts.BoilerRoom}

  def mount(_assigns, session, socket),
    do: {:ok, default_assigns(socket, session)}

  def render(assigns),
    do: Phoenix.View.render(IpartyWeb.BoilerRoomView, "create.html", assigns)

  def handle_event("save", %{"boiler_room" => boiler_room_params}, socket) do
    merge = %{
      "slug" => Iparty.Base.Generator.gen_slug(),
      "user_id" => socket.assigns.user.id,
      "online" => false,
      "views" => 0
    }

    params = Map.merge(boiler_room_params, merge)

    case Accounts.create_boiler_room(params) do
      {:ok, room} ->
        {:noreply,
         socket
         |> put_flash(:info, "BOILER ROOM created!")
         |> redirect(to: Routes.boiler_room_path(socket, :show, room.slug))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp default_assigns(socket, session) do
    changeset = BoilerRoom.changeset(%BoilerRoom{})

    socket
    |> assign(:changeset, changeset)
    |> assign(:tags, [])
    |> assign(:user, session["user"])
  end
end
