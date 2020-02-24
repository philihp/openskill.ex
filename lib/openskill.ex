defmodule Openskill do
  alias Openskill.{Environment, Rating, Util}

  @env %Environment{}

  def rating(mu \\ nil, sigma \\ nil) do
    {mu || @env.mu, sigma || @env.sigma}
  end

  def rate(rating_groups, options \\ []) do
    defaults = [
      weights: Util.default_weights(rating_groups),
      ranks: Util.default_ranks(rating_groups),
      model: Openskill.PlackettLuce
    ]

    options = Keyword.merge(defaults, options) |> Enum.into(%{})
    options.model.rate(rating_groups, options)
  end
end
