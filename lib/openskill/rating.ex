defmodule Openskill.Rating do
  @enforce_keys [:mu, :sigma]
  defstruct [:mu, :sigma]

  alias Openskill.{Rating, Environment}

  @env %Environment{}

  def new(mu, sigma) do
    %Rating{
      mu: mu || @env.mu,
      sigma: sigma || @env.sigma
    }
  end
end
