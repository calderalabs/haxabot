defmodule Haxabot.Server do
  use Slack

  defmodule State do
    defstruct id: nil, name: nil
  end

  def handle_connect(slack, _state) do
    IO.puts "Connected as #{slack.me.name}"
    {:ok, %State{id: slack.me.id, name: slack.me.name}}
  end

  def handle_event(%{type: "message", text: text} = message, slack, state) do
    cond do
      Regex.match?(~r/apina/, text) -> send_message(get_apina(), message.channel, slack)
      Regex.match?(~r/(<@#{state.id}>|#{state.name})/, text) -> send_message("lul", message.channel, slack)
      true -> :ok
    end
    {:ok, state}
  end
  def handle_event(message = %{type: "message"}, _slack, state) do
    IO.puts "Received message #{inspect message}"
    {:ok, state}
  end
  def handle_event(_, _, state), do: {:ok, state}

  def handle_info({:message, text, channel}, slack, state) do
    IO.puts "Sending your message, captain!"

    send_message(text, channel, slack)

    {:ok, state}
  end
  def handle_info(_, _, state), do: {:ok, state}

  defp get_apina do
    res = HTTPoison.get!("http://apinaporn.com/random", %{}, hackney: [cookie: ["i_need_it_now=fapfap"]])
    {"Location", value} = List.keyfind(res.headers, "Location", 0)
    [[id]] = Regex.scan(~r/\d+/, value)
    "http://apinaporn.com/#{id}.jpg"
  end
end
