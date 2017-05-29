defmodule Haxabot.Server do
  use GenServer

  defmodule State do
    defstruct parent: nil
  end

  @available_commands [
    {~r/^apina/, :apina},
    {~r//, :catch_all}
  ]
  def start_link(parent) do
    GenServer.start_link(__MODULE__, parent)
  end

  def receive_command(pid, command) do
    GenServer.call(pid, {:receive_command, command})
  end

  def init(parent) do
    {:ok, %State{parent: parent}}
  end

  def handle_call({:receive_command, command}, _from, state) do
    result =
      @available_commands
      |> Enum.find(fn {regex, _} ->
        Regex.match?(regex, command.text)
      end)

    new_state =
      case result do
        nil -> state
        {_regex, atom} ->
          {:ok, new_state} = apply(__MODULE__, atom, [command, state])
          new_state
      end

    {:reply, :ok, new_state}
  end

  def apina(%{message: message}, state) do
    send_message(get_apina_random_url(), message.channel, state)
    {:ok, state}
  end

  def catch_all(%{message: message}, state) do
    send_message("I don't know what to do with that", message.channel, state)
    {:ok, state}
  end

  def get_apina_random_url do
    apina_client = Application.get_env(:haxabot, :apina_client) || Haxabot.ApinaClient
    apina_client.get_random_url()
  end

  defp send_message(text, channel, %{parent: parent}) do
    send parent, {:message, text, channel}
  end
end
