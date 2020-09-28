defmodule Iparty.Base.Pagination do
  import Ecto.Query
  alias Iparty.{Repo, Accounts.BoilerRoom}
  @per_page 25

  @type t :: %__MODULE__{
          enabled: boolean(),
          total_items: integer(),
          total_pages: integer(),
          current_page: integer(),
          last_item_id: integer(),
          nav_between: list(),
          items: list()
        }

  @enforce_keys [
    :enabled,
    :total_items,
    :total_pages,
    :current_page,
    :items,
    :last_item_id,
    :nav_between
  ]

  defstruct [
    :enabled,
    :total_items,
    :total_pages,
    :current_page,
    :items,
    :last_item_id,
    :nav_between
  ]

  def generate(BoilerRoom, :online_rooms),
    do: online_rooms()

  defp online_rooms() do
    # Showing only online rooms by default
    online_rooms_query = from br in BoilerRoom, where: br.online and br.status == ^"public"
    online_rooms_count_query = from r in online_rooms_query, select: count(r.id)
    online_count = Repo.one(online_rooms_count_query)

    rooms = from br in online_rooms_query, limit: @per_page

    items = Repo.all(rooms)
    total_pages = (online_count / @per_page) |> ceil()
    enabled = total_pages > 1
    last_item = items |> List.last()
    between = calc_nav_between(total_pages, 1)

    %__MODULE__{
      items: items,
      current_page: 1,
      enabled: enabled,
      nav_between: between,
      total_items: online_count,
      total_pages: total_pages,
      last_item_id: last_item.id
    }
  end

  defp calc_nav_between(1, _), do: []
  defp calc_nav_between(2, _), do: []
  defp calc_nav_between(3, _), do: [2]
  defp calc_nav_between(4, _), do: [2, 3]
  defp calc_nav_between(5, _), do: [2, 3, 4]
  defp calc_nav_between(6, _), do: [2, 3, 4, 5]
  defp calc_nav_between(7, _), do: [2, 3, 4, 5, 6]

  defp calc_nav_between(_, current) when is_integer(current) do
    one = current - 2
    two = current - 1
    four = current + 1
    five = current + 2
    [one, two, current, four, five]
  end

  # def generate(BoilerRoom, :total_rooms),
  #   do: total_rooms()

  # defp total_rooms() do
  #   online_rooms_query = from br in BoilerRoom, where: br.online and br.status == ^"public"
  #   online_rooms_count_query = from r in online_rooms_query, select: count(r.id)
  #   online_count = Repo.one(online_rooms_count_query)

  #   offline_rooms_query = from br in BoilerRoom, where: not br.online and br.status == ^"public"
  #   offline_rooms_count_query = from r in online_rooms_query, select: count(r.id)
  #   offline_count = Repo.one(online_rooms_count_query)
  # end
end
