defmodule Iparty.BoilerRoomPresence do
  use Phoenix.Presence, otp_app: :iparty, pubsub_server: Iparty.PubSub
end
