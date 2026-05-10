defmodule Openskill.Environment do
  @z 3
  @mu 25
  @sigma @mu / @z
  @beta @sigma / 2
  @epsilon 0.0001
  @tau 1 / 3
  @prevent_sigma_increase false

  defstruct mu: @mu,
            sigma: @sigma,
            beta: @beta,
            epsilon: @epsilon,
            z: @z,
            tau: @tau,
            prevent_sigma_increase: @prevent_sigma_increase
end
