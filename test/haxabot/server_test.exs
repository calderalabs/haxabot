defmodule Haxabot.ServerTest do
  use ExUnit.Case

  alias Haxabot.Server
  alias Haxabot.ServerTest.TestApinaClient

  defmodule TestApinaClient do
    def start_link do
      Agent.start_link(fn -> :empty end, name: __MODULE__)
    end

    def get_random_url() do
      Agent.get(__MODULE__, &(&1))
    end

    def set_state(url) do
      Agent.update(__MODULE__, fn(_) -> url end)
    end
  end

  setup do
    TestApinaClient.start_link()
    Application.put_env(:haxabot, :apina_client, TestApinaClient)
    {:ok, pid} = Haxabot.Server.start_link(self())
    %{server: pid}
  end

  test "it replies with catch all", %{server: pid} do
    Server.receive_command(pid, %{text: "hello", message: %{channel: "mine"}})
    assert_receive {:message, "I don't know what to do with that", "mine"}
  end

  test "it replies with apina", %{server: pid} do
    TestApinaClient.set_state("http://apina.com/1234")
    Server.receive_command(pid, %{text: "apina", message: %{channel: "mine"}})
    assert_receive {:message, "http://apina.com/1234", "mine"}
  end
end
