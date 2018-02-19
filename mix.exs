defmodule Haxabot.Mixfile do
  use Mix.Project

  def project do
    [app: :haxabot,
     version: "0.1.1",
     elixir: "~> 1.6",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    opts = [extra_applications: [:logger]]

    case Mix.env do
      :test -> opts
      _ -> Keyword.put(opts, :mod, {Haxabot.Application, []})
    end
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:slack, "~> 0.12.0"},
     {:httpoison, "~> 0.11.0"},
     {:redix, "~> 0.7.0"}]
  end
end
