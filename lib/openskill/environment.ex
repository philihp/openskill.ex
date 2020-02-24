defmodule Openskill.Environment do
  @mu 25
  @sigma @mu / 3
  @beta @sigma / 2
  @tau @sigma / 100
  @draw_probability 0.10
  @delta 0.0001

  defstruct mu: @mu,
            sigma: @sigma,
            beta: @beta,
            tau: @tau,
            draw_probability: @draw_probability,
            delta: @delta
end
