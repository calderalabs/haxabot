defmodule Haxabot.Commands.Apina.For do
  import Haxabot.Commands.Helpers

  def run([user], message, state) do
    "#{user}: #{Haxabot.Commands.Apina.get_random_url()}"
    |> send_message(message.channel, state)
    {:ok, state}
  end
end
