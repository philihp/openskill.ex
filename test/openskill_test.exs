defmodule OpenskillTest do
  alias Openskill.{Environment, Rating}

  @epsilon 0.001
  @env %Environment{mu: 1500, sigma: 100}

  use ExUnit.Case

  describe "#rating" do
    test "returns a default rating" do
      %Rating{mu: mu, sigma: sigma} = Openskill.rating()
      assert_in_delta mu, 25, @epsilon
      assert_in_delta sigma, 8.333, @epsilon
    end

    test "returns an initialized rating" do
      %Rating{mu: mu, sigma: sigma} = Openskill.rating(1500, 32)
      assert mu == 1500
      assert sigma == 32
    end
  end
end
