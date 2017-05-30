defmodule Haxabot.Commands.Apina.Bomb do
  import Haxabot.Commands.Helpers

  @bomb_limit 100

  def run([count], message, state) do
    {count, ""} = Integer.parse(count)
    do_run(count, message, state)
  end

  defp do_run(count, message, state) when count < @bomb_limit do
    Stream.repeatedly(&Haxabot.Commands.Apina.get_random_url/0)
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
end
