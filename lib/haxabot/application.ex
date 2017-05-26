defmodule Haxabot.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Slack.Bot, [Haxabot.Server, [], get_slack_token()])
    ]

    opts = [strategy: :one_for_one, name: Haxabot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp get_slack_token do
    System.get_env("SLACK_TOKEN")
  end
end
