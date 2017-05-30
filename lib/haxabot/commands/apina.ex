defmodule Haxabot.Commands.Apina do
  import Haxabot.Commands.Helpers

  @available_commands [
    {~r/bomb (\d+)/, :bomb},
    {~r/(.+)/, :basic}
  ]

  @bomb_limit 100

  def run(%{text: text, message: message}, state) do
    result =
      @available_commands
      |> Enum.reduce_while(:not_found, fn ({regex, atom}, acc) ->
        case Regex.scan(regex, text) do
          [] -> {:cont, acc}
          [matches] -> {:halt, {atom, matches}}
        end
      end)

    case result do
      :not_found ->
        {:ok, state}

      {atom, matches} ->
        {:ok, new_state} = apply(__MODULE__, atom, [matches, message, state])
        {:ok, new_state}
    end
  end

  def bomb([_, count], message, state) do
    {count, ""} = Integer.parse(count)
    do_bomb(count, message, state)
  end

  defp do_bomb(count, message, state) when count < @bomb_limit do
    Stream.repeatedly(&get_random_url/0)
    |> Enum.reduce_while(MapSet.new, fn url, acc ->
      new_acc = MapSet.put(acc, url)
      case MapSet.size(new_acc) do
        ^count -> {:halt, new_acc}
        _other -> {:cont, new_acc}
      end
    end)
    |> Enum.each(fn url ->
      send_message(url, message.channel, state)
    end)

    {:ok, state}
  end

  def basic(_matches, message, state) do
    send_message(get_random_url(), message.channel, state)
    {:ok, state}
  end

  def get_random_url do
    client = Application.get_env(:haxabot, :apina_client) || Haxabot.ApinaClient
    client.get_random_url()
  end
end
