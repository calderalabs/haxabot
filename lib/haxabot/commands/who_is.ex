defmodule Haxabot.Commands.WhoIs do
  import Haxabot.Commands.Helpers

  def run(%{text: "who is " <> name, message: message}, state) do
    run(%{text: "whois " <> name, message: message}, state)
  end
  def run(%{text: "whois " <> name, message: %{channel: channel}}, state) do
    message =
      case fetch_user(name, state) do
        {:ok, result} -> "#{name} is #{make_sentence(result)}"
        :empty -> "I don't know who #{name} is"
      end

    send_message(message, channel, state)
    {:ok, state}
  end
  def run(%{text: "forget " <> name, message: %{channel: channel}}, state) do
    delete_user(name, state)
    send_message("done", channel, state)
    {:ok, state}
  end
  def run(%{text: text, message: %{channel: channel}}, state) do
    result =
      case Regex.scan(~r/^(.+) is (.+)$/, text) do
        [] -> :error
        [[_, name, description]] ->
          update_user(name, description, state)
          :ok
      end

    message =
      case result do
        :error -> "I'm not sure what you want me to do"
        :ok -> "gotcha"
      end

    send_message(message, channel, state)
    {:ok, state}
  end

  defp fetch_user(name, %{redis_conn: redis_conn}) do
    {:ok, result} = Redix.command(redis_conn, ["LRANGE", key_for(name), 0, -1])

    case result do
      [] -> :empty
      _ -> {:ok, result}
    end
  end

  defp update_user(name, description, %{redis_conn: redis_conn}) do
    {:ok, _} = Redix.command(redis_conn, ["RPUSH", key_for(name), description])
  end

  defp delete_user(name, %{redis_conn: redis_conn}) do
    {:ok, _} = Redix.command(redis_conn, ["DEL", key_for(name)])
  end

  defp key_for(name), do: "whois.#{name}"

  defp make_sentence([description]), do: description
  defp make_sentence(list) do
    initials = Enum.slice(list, 0..-2)
    last = List.last(list)
    "#{Enum.join(initials, ", ")} and #{last}"
  end
end
