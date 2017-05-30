defmodule Haxabot.Commands.Greeting do
  import Haxabot.Commands.Helpers

  def run(%{text: "hello", message: %{user: user, channel: channel}}, state) do
    "<@#{user}> hi"
    |> send_message(channel, state)
    {:ok, state}
  end
  def run(%{text: "hi", message: %{user: user, channel: channel}}, state) do
    "<@#{user}> hello"
    |> send_message(channel, state)
    {:ok, state}
  end
  def run(%{text: "ping", message: %{user: user, channel: channel}}, state) do
    "<@#{user}> pong"
    |> send_message(channel, state)
    {:ok, state}
  end
end
