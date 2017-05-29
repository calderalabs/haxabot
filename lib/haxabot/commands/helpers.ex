defmodule Haxabot.Commands.Helpers do
  def send_message(text, channel, %{parent: parent} = _server_state) do
    send parent, {:message, text, channel}
  end
end
