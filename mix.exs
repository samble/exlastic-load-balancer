defmodule ExlasticLB.Mixfile do
  use Mix.Project

  def project do
    [app: :exlasticlb,
     version: "0.0.1",
     elixir: "~> 1.0",
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [
      applications: [:logger]
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      # a linter for elixir code
      {:dogma, "~> 0.1", only: :dev},

      # a static analysis tool
      {:dialyxir, "~> 0.3", only: [:dev]},

      # a json parser
      {:poison, "2.2.0"},

      {:erlcloud, git: "https://github.com/samble/erlcloud-aws-get-metric-statistics.git"}
    ]
  end
end
