defmodule IpartyWeb.Live.Component.BoilerRoom.PlaylistHeader do
  use IpartyWeb, :live_component

  def render(assigns) do
    ~L"""
    <div class="flex justify-center items-center h-8 mt-3">
      <div class="flex flex-row justify-start items-center bg-gray-100 dark:bg-erie-black-500 shadow rounded-md w-11/12 px-4 py-2">
        <span class="text-lg font-medium text-indigo-500 dark:text-sage-500 font-roboto mr-2">
          Playlist
        </span>

        <button data-tooltip="Save playlist" phx-target="<%= @myself %>" phx-click="save" class="tooltip flex justify-center items-center bg-blue-300 dark:bg-sage-500 text-gray-800 opacity-75 rounded-lg w-8 h-6 mr-2 hover:bg-blue-400 dark:hover:bg-silver-300 hover:text-gray-900 hover:opacity-100 focus:outline-none">
          <i class="fad fa-save"></i>
        </button>

        <button data-tooltip="Shufle playlist" phx-target="<%= @myself %>" phx-click="shufle" class="tooltip flex justify-center items-center bg-blue-300 dark:bg-sage-500 text-gray-800 opacity-75 rounded-lg w-8 h-6 mr-2 hover:bg-blue-400 dark:hover:bg-silver-300 hover:text-gray-900 hover:opacity-100 focus:outline-none">
          <i class="fad fa-random"></i>
        </button>

        <button data-tooltip="Repeat playlist" phx-target="<%= @myself %>" phx-click="repeat" class="tooltip flex justify-center items-center bg-blue-300 dark:bg-sage-500 text-gray-800 opacity-75 rounded-lg w-8 h-6 mr-2 hover:bg-blue-400 dark:hover:bg-silver-300 hover:text-gray-900 hover:opacity-100 focus:outline-none">
          <i class="fad fa-repeat-alt"></i>
        </button>
      </div>
    </div>

    """
  end
end
