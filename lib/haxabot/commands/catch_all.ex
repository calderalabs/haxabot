defmodule Haxabot.Commands.CatchAll do
  import Haxabot.Commands.Helpers

  def run(%{message: message}, state) do
    send_message("I don't know what to do with that", message.channel, state)
    {:ok, state}
  end
end
