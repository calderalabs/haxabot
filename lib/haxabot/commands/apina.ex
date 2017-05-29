defmodule Haxabot.Commands.Apina do
  import Haxabot.Commands.Helpers

  def run(%{message: message}, state) do
    send_message(get_random_url(), message.channel, state)
    {:ok, state}
  end

  def get_random_url do
    client = Application.get_env(:haxabot, :apina_client) || Haxabot.ApinaClient
    client.get_random_url()
  end
end
