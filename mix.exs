defmodule ExlasticLB.Mixfile do
  use Mix.Project

  def project do
    [app: :exlasticlb,
     version: "0.0.1",
     package: package,
     test_coverage: [
       tool: Coverex.Task,
       console_log: true],
     elixir: "~> 1.0",
     escript: [main_module: ExlasticLB.CommandLine, app: nil],
     deps: deps]
  end

  # Configuration for the OTP application
  # Type `mix help compile.app` for more information
  def application do
    [
      applications: [:logger],
      mod: {ExlasticLB, [Mix.env]},
    ]
  end

  # Dependencies can be Hex packages:
  #   {:mydep, "~> 0.3.0"}
  # Or git/path repositories:
  #   {:mydep, git: "https://github.com/elixirlang/mydep.git", tag: "0.1.0"}
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      # a linter for elixir code
      {:dogma, "~> 0.1", only: :dev},

      # NB: 0.1.4 is available on github but not hex currently
      {:mock, "~> 0.1.4", git: "https://github.com/jjh42/mock.git"},

      # meck is required by mock, but version collides with ercloud,
      # so it is required to be explicit here explicit
      { :meck, ~r/.*/,
          [ env: :prod,
            git: "https://github.com/eproxus/meck.git",
            tag: "0.8.4",
            manager: :rebar,
            override: true]},

      # a static analysis tool
      {:dialyxir, "~> 0.3", only: [:dev]},

      # coverage tool for tests
      # https://github.com/alfert/coverex
      {:coverex, "~> 1.4.9", only: :test},

      # a json parser
      {:poison, "2.2.0"},

      # a cronlike scheduling library.
      # see `config/config.exs` for job scheduling
      {:quantum, ">= 1.7.1"},

      { :erlcloud,
        git: "https://github.com/samble/erlcloud-aws-get-metric-statistics.git"
      },

      # http proxy server requirements
      {:cowboy, "~> 1.0.0"},
      {:plug, "~> 1.0"},

    ]
  end
  defp package do
    [
      files: [],
      contributors: [
        "",
      ],
      maintainers: [""],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "",
        "Docs"   => ""
      }
    ]
  end
end
