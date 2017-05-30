defmodule Haxabot.Commands.Apina do
  alias Haxabot.Commands.Apina

  @available_commands [
    {~r/^bomb (\d+)/, Apina.Bomb},
    {~r/^(?:for|per) (<?@?\w+>?)/, Apina.For},
    {~r//, Apina.Basic}
  ]

  def run(%{text: "apina" <> text, message: message}, state) do
    text = text |> String.trim

    result =
      @available_commands
      |> Enum.reduce_while(:not_found, fn ({regex, mod}, acc) ->
        case Regex.scan(regex, text) do
          [] -> {:cont, acc}
          [[_|matches]] -> {:halt, {mod, matches}}
        end
      end)

    case result do
      :not_found ->
        {:ok, state}

      {mod, matches} ->
        {:ok, new_state} = apply(mod, :run, [matches, message, state])
        {:ok, new_state}
    end
  end

  def get_random_url do
    client = Application.get_env(:haxabot, :apina_client) || Haxabot.ApinaClient
    client.get_random_url()
  end
end
