defmodule Openskill.ThurstoneMostellerFullTest do
  use ExUnit.Case
  alias Openskill.ThurstoneMostellerFull

  @r Openskill.rating()
  @team1 [@r]
  @team2 [@r, @r]
  @team3 [@r, @r, @r]

  describe "#rate" do
    test "2p FFA" do
      assert [
               [{29.230718726575056, 7.783287759506231}],
               [{20.769281273424944, 7.783287759506231}]
             ] == ThurstoneMostellerFull.rate([@team1, @team1])
    end

    test "3p FFA" do
      assert [
               [{33.46143745315011, 7.591087514198776}],
               [{25.0, 7.591087514198776}],
               [{16.53856254684989, 7.591087514198776}]
             ] == ThurstoneMostellerFull.rate([@team1, @team1, @team1])
    end

    test "4p FFA" do
      assert [
               [{37.692156179725174, 7.493138881583409}],
               [{29.230718726575056, 7.493138881583409}],
               [{20.769281273424944, 7.493138881583409}],
               [{12.30784382027483, 7.493138881583409}]
             ] == ThurstoneMostellerFull.rate([@team1, @team1, @team1, @team1])
    end

    test "5p FFA" do
      assert [
               [{41.92287490630022, 7.433750243919993}],
               [{33.46143745315011, 7.433750243919993}],
               [{25.0, 7.433750243919993}],
               [{16.538562546849885, 7.433750243919993}],
               [{8.077125093699774, 7.433750243919993}]
             ] == ThurstoneMostellerFull.rate([@team1, @team1, @team1, @team1, @team1])
    end

    test "3 teams different sized players" do
      assert [
               [
                 {25.729796806262755, 8.253198719658853},
                 {25.729796806262755, 8.253198719658853},
                 {25.729796806262755, 8.253198719658853}
               ],
               [{34.02513861155437, 7.978290956611053}],
               [{15.24506458218288, 7.9082660983526445}, {15.24506458218288, 7.9082660983526445}]
             ] == ThurstoneMostellerFull.rate([@team3, @team1, @team2])
    end

    test "1v1 win and then loss decreases mu" do
      alice1 = @r
      betty1 = @r
      [[alice2], [betty2]] = ThurstoneMostellerFull.rate([[alice1], [betty1]])
      [[alice3], [betty3]] = ThurstoneMostellerFull.rate([[betty2], [alice2]])

      assert [{26.97819106220699, 7.185640185216057}, {23.02180893779301, 7.185640185216057}] == [
               alice3,
               betty3
             ]
    end
  end
end
