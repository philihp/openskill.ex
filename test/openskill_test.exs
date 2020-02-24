defmodule OpenskillTest do
  use ExUnit.Case
  @epsilon 0.001

  describe "#rating" do
    test "returns a default rating" do
      {mu, sigma} = Openskill.rating()
      assert mu == 25.0
      assert_in_delta sigma, 8.333, @epsilon
    end

    test "returns a rating with just mu initialized" do
      {mu, sigma} = Openskill.rating(100)
      assert mu == 100
      assert_in_delta sigma, 8.333, @epsilon
    end

    test "returns an initialized rating" do
      {mu, sigma} = Openskill.rating(1500, 32)
      assert mu == 1500
      assert sigma == 32
    end
  end
end
