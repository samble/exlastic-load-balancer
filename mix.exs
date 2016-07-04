defmodule ExlasticLB.Mixfile do
  use Mix.Project

  def project do
    [app: :exlasticlb,
     version: "0.0.1",
     test_coverage: [
       tool: Coverex.Task,
       console_log: true],
     elixir: "~> 1.0",
     escript: [main_module: ExlasticLB, app: nil],
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [
      applications: [
        :logger,
        #:quantum,
        #:exlasticlb,
      ],
      mod: {ExlasticLB, [Mix.env]},
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

      # coverage tool for tests
      # https://github.com/alfert/coverex
      {:coverex, "~> 1.4.9", only: :test},

      # a json parser
      {:poison, "2.2.0"},

      # a cron-like scheduling library.  see `config/config.exs` for job scheduling
       {:quantum, ">= 1.7.1"},

      {:erlcloud, git: "https://github.com/samble/erlcloud-aws-get-metric-statistics.git"}
    ]
  end
end
