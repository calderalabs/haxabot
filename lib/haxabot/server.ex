defmodule Haxabot.Server do
  use GenServer

  alias Haxabot.Commands

  defmodule State do
    defstruct parent: nil
  end

  @available_commands [
    {~r/^apina/, Commands.Apina},
    {~r/^(hello|hi|ping)$/, Commands.Greeting},
    {~r//, Commands.CatchAll}
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
        {_regex, mod} ->
          {:ok, new_state} = apply(mod, :run, [command, state])
          new_state
      end

    {:reply, :ok, new_state}
  end
end
