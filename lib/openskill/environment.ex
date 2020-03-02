defmodule Openskill.Environment do
  @z 3
  @mu 25
  @sigma @mu / @z
  @beta @sigma / 2
  @epsilon 0.0001

  defstruct mu: @mu,
            sigma: @sigma,
            beta: @beta,
            epsilon: @epsilon,
            z: @z
end
