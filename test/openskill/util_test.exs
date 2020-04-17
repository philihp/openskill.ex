defmodule Openskill.UtilTest do
  alias Openskill.Util
  use ExUnit.Case
  @epsilon 0.001

  describe "#team_rating" do
    test "aggregates team data" do
      r = Openskill.rating()
      t1 = [r, r, r]
      t2 = [r]
      t3 = [r, r]

      [
        {mu1, sigma1, team1, i1},
        {mu2, sigma2, team2, i2},
        {mu3, sigma3, team3, i3}
      ] = Util.team_rating([t1, t2, t3])

      assert 75 == mu1
      assert 25 == mu2
      assert 50 == mu3
      assert_in_delta sigma1, 208.3333, @epsilon
      assert_in_delta sigma2, 69.4444, @epsilon
      assert_in_delta sigma3, 138.8889, @epsilon
      assert team1 == t1
      assert team2 == t2
      assert team3 == t3
      assert i1 == 1
      assert i2 == 2
      assert i3 == 3
    end
  end

  describe "#ladder_pairs" do
    test "two element ranks" do
      assert [[2], [1]] ==
               Util.ladder_pairs([1, 2])
    end

    test "three element ranks" do
      assert [[2], [1, 3], [2]] ==
               Util.ladder_pairs([1, 2, 3])
    end

    test "four element ranks" do
      assert [[2], [1, 3], [2, 4], [3]] ==
               Util.ladder_pairs([1, 2, 3, 4])
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

  describe "#v" do
    test "denominator less than threshold" do
      assert 9900 = Util.v(-10000, -100)
    end
  end

  describe "#w" do
    test "denominator less than threshold" do
      assert 1 = Util.w(-10000, -100)
    end
  end

  describe "#vt" do
    test "b small, x small" do
      assert 1100 = Util.vt(-1000, -100)
    end

    test "b small, x big" do
      assert -1100 = Util.vt(1000, -100)
    end

    test "b big, x small" do
      assert 0.7978845600049808 = Util.vt(-1000, 1000)
    end

    test "b big, x big" do
      assert 0.0 = Util.vt(0, 1000)
    end
  end

  describe "#wt" do
    test "under threshold, so just use 1.0" do
      assert 1.0 = Util.wt(0, 0)
    end

    test "standard operating protocol" do
      assert Util.wt(0, 10) < 0.00000000001
    end
  end
end
