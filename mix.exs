defmodule Openskill.MixProject do
  use Mix.Project

  def project do
    [
      app: :openskill,
      version: "0.1.0",
      elixir: "~> 1.9",
      description: description(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: [
        maintainers: ["Philihp Busby"],
        licenses: ["MIT"],
        links: %{github: "https://github.com/philihp/openskill"}
      ]
    ]
  end

  def description do
    """
    Weng-Lin Bayesian approximation method for online skill-ranking.

    Orders of magnitude faster over Microsoft TrueSkill, with better prediction, and commercial usage does not require a license.
    """
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false},
      {:math, "~> 0.5.0"},
      {:statistics, "~> 0.6.2"}
    ]
  end
end
