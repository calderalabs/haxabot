defmodule Haxabot.ServerTest do
  use ExUnit.Case

  alias Haxabot.Server
  alias Haxabot.ServerTest.TestApinaClient

  defmodule TestApinaClient do
    def start_link do
      Agent.start_link(fn -> {[], 0} end, name: __MODULE__)
    end

    def get_random_url() do
      Agent.get_and_update(__MODULE__, fn {list, count} ->
        case Enum.at(list, count) do
          nil -> {nil, {list, count}}
          value -> {value, {list, count+1}}
        end
      end)
    end

    def set_state(urls) when is_list(urls) do
      Agent.update(__MODULE__, fn(_) -> {urls, 0} end)
    end
    def set_state(url) do
      set_state([url])
    end
  end

  setup do
    TestApinaClient.start_link()
    Application.put_env(:haxabot, :apina_client, TestApinaClient)
    {:ok, pid} = Haxabot.Server.start_link(self())
    %{server: pid}
  end

  test "it replies with catch all", %{server: pid} do
    Server.receive_command(pid, %{text: "gibberish", message: %{channel: "mine"}})
    assert_receive {:message, "I don't know what to do with that", "mine"}
  end

  test "it replies with apina", %{server: pid} do
    TestApinaClient.set_state("http://apina.com/1234")
    Server.receive_command(pid, %{text: "apina", message: %{channel: "mine"}})
    assert_receive {:message, "http://apina.com/1234", "mine"}
  end

  test "it replies with apina followed by any string", %{server: pid} do
    TestApinaClient.set_state("http://apina.com/1234")
    Server.receive_command(pid, %{text: "apina del bongi bongi", message: %{channel: "mine"}})
    assert_receive {:message, "http://apina.com/1234", "mine"}
  end

  test "it replies with apina bomb", %{server: pid} do
    TestApinaClient.set_state([
      "http://apina.com/1234",
      "http://apina.com/1235",
      "http://apina.com/1236",
      "http://apina.com/1237"
    ])
    Server.receive_command(pid, %{text: "apina bomb 3", message: %{channel: "mine"}})
    assert_receive {:message, "http://apina.com/1234", "mine"}
    assert_receive {:message, "http://apina.com/1235", "mine"}
    assert_receive {:message, "http://apina.com/1236", "mine"}
  end

  test "it filters out duplicates with apina bomb", %{server: pid} do
    TestApinaClient.set_state([
      "http://apina.com/1234",
      "http://apina.com/1234",
      "http://apina.com/1234",
      "http://apina.com/1235",
      "http://apina.com/1236",
    ])
    Server.receive_command(pid, %{text: "apina bomb 3", message: %{channel: "mine"}})
    assert_receive {:message, "http://apina.com/1234", "mine"}
    assert_receive {:message, "http://apina.com/1235", "mine"}
    assert_receive {:message, "http://apina.com/1236", "mine"}
  end

  test "it replies with custom apina", %{server: pid} do
    TestApinaClient.set_state("http://apina.com/1234")
    Server.receive_command(pid, %{text: "apina per i fioi", message: %{channel: "mine"}})
    assert_receive {:message, "i fioi http://apina.com/1234", "mine"}
  end

  test "it recognizes me as a special username", %{server: pid} do
    TestApinaClient.set_state("http://apina.com/1234")
    Server.receive_command(pid, %{text: "apina per me", message: %{user: "1234", channel: "mine"}})
    assert_receive {:message, "<@1234> http://apina.com/1234", "mine"}
  end

  test "it says hi", %{server: pid} do
    Server.receive_command(pid, %{text: "hello", message: %{user: "1234", channel: "mine"}})
    assert_receive {:message, "<@1234> hi", "mine"}
  end

  test "it says pong", %{server: pid} do
    Server.receive_command(pid, %{text: "ping", message: %{user: "1234", channel: "mine"}})
    assert_receive {:message, "<@1234> pong", "mine"}
  end
end
