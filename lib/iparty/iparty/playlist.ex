defmodule PlayList do
  @pl_len_limit 35
  defstruct play_items: [], play_ids: [], max_length: @pl_len_limit,length: 0, repeat: false

  def add(%PlayList{length: len} = p_list, %PlayItem{} = p_item) when len < @pl_len_limit do
    new_list = %{
      p_list
      | play_items: p_list.play_items ++ [p_item],
        play_ids: p_list.play_ids ++ [p_item.id],
        length: len + 1
    }

    {:ok, new_list}
  end

  def add(%PlayList{length: len} = p_list, %PlayItem{}) when len >= @pl_len_limit,
    do: {:error, ["Can't add more items to playlist, #{@pl_len_limit} is the limit.", p_list]}

  def add(nil, nil), do: {:error, ["PlayList and PlayItem can't be nil", nil]}
  def add(nil, _), do: {:error, ["PlayList item can't be nil", nil]}
  def add(_, nil), do: {:error, ["PlayItem item can't be nil", nil]}

  def remove(%PlayList{length: len} = p_list, %PlayItem{} = p_item) when len > 0 do
    new_list = %{
      p_list
      | play_items: List.delete(p_list.play_items, p_item),
        play_ids: List.delete(p_list.play_ids, p_item.id),
        length: len - 1
    }

    {:ok, new_list}
  end

  def remove(%PlayList{length: len} = p_list, %PlayItem{}) when len <= 0,
    do: {:error, ["Playlist empty!", p_list]}

  def remove(%PlayList{} = p_list, _), do: {:ok, p_list}

  def get_item(%PlayList{play_items: items}, uuid),
    do: items |> Enum.find(&(&1.uuid == uuid))

  def shuffle(%PlayList{play_items: items} = pl) do
    new_pl = %{
      pl
      | play_items: Enum.shuffle(items)
    }

    {:ok, new_pl}
  end
end
