defmodule Openskill do
  alias Openskill.{Rating}

  def rating(mu \\ nil, sigma \\ nil) do
    Rating.new(mu, sigma)
  end
end
