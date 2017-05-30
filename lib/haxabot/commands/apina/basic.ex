defmodule Haxabot.Commands.Apina.Basic do
  import Haxabot.Commands.Helpers

  def run(_matches, message, state) do
    send_message(Haxabot.Commands.Apina.get_random_url(), message.channel, state)
    {:ok, state}
  end
end
