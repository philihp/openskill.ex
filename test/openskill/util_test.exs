defmodule Openskill.UtilTest do
  alias Openskill.Util
  use ExUnit.Case
  @epsilon 0.001

  describe "#team_rating" do
    test "aggregates team data" do
      r = Openskill.rating()

      [{mu1, sigma1}, {mu2, sigma2}, {mu3, sigma3}] =
        Util.team_rating([
          [r, r, r],
          [r],
          [r, r]
        ])

      assert 75 == mu1
      assert 25 == mu2
      assert 50 == mu3
      assert_in_delta sigma1, 208.3333, @epsilon
      assert_in_delta sigma2, 69.4444, @epsilon
      assert_in_delta sigma3, 138.8889, @epsilon
    end
  end

  describe "#default_weights" do
    test "empty list" do
      assert [] = Util.default_weights([])
    end

    test "two player game" do
      assert [[1], [1]] = Util.default_weights([[:a], [:b]])
    end

    test "simple list" do
      assert [[1], [1], [1], [1], [1]] = Util.default_weights([[:a], [:b], [:c], [:d], [:e]])
    end

    test "team game" do
      assert [[1, 1, 1], [1, 1, 1]] = Util.default_weights([[:a, :b, :c], [:d, :e, :f]])
    end
  end

  describe "#default_ranks" do
    test "empty list" do
      assert [] = Util.default_ranks([])
    end

    test "two player game" do
      assert [1, 2] = Util.default_ranks([[:a], [:b]])
    end

    test "simple list" do
      assert [1, 2, 3, 4, 5] = Util.default_ranks([[:a], [:b], [:c], [:d], [:e]])
    end

    test "team game" do
      assert [1, 2] = Util.default_ranks([[:a, :b, :c], [:d, :e, :f]])
    end
  end
end
