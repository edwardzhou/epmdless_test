defmodule EpmdlessTest.MixProject do
  use Mix.Project

  def project do
    [
      app: :epmdless_test,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: releases_apps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :sasl, :epmdless],
      mod: {EpmdlessTest.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:epmdless, "~> 0.3.0"},
      {:libcluster, "~> 3.3.0"}
    ]
  end

  defp releases_apps do
    [
      epmdless_test: [
        cookie: "abc123",
        applications: [epmdless_test: :permanent]
      ]
    ]
  end
end
