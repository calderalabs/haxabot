defmodule Haxabot.Slack do
  use Slack

  defmodule State do
    defstruct id: nil, name: nil, server: nil
  end

  def handle_connect(%{me: %{name: name, id: id}} = _slack, _state) do
    IO.puts "Connected as #{name} with id #{id}"
    {:ok, server} = Haxabot.Server.start_link(self())
    {:ok, %State{id: id, name: name, server: server}}
  end

  def handle_event(%{type: "message", text: text, user: user_id} = message, _slack,
                   %{id: id, name: name, server: server} = state) when user_id != id do

    case Regex.scan(~r/^(<@#{id}>|#{name}):? (.+)/, text) do
      [] -> :ok
      [[_, _id_or_name, text]] ->
        Haxabot.Server.receive_command(server, %{text: text, message: message})
    end

    {:ok, state}
  end
  def handle_event(message, _, state) do
    IO.inspect message
    {:ok, state}
  end

  def handle_info({:message, text, channel}, slack, state) do
    send_message(text, channel, slack)
    {:ok, state}
  end
  def handle_info(_, _, state), do: {:ok, state}
end
