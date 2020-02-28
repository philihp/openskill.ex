defmodule Openskill.ThurstoneMostellerPartTest do
  use ExUnit.Case
  alias Openskill.ThurstoneMostellerPart

  @r Openskill.rating()
  @team1 [@r]
  @team2 [@r, @r]
  @team3 [@r, @r, @r]

  describe "#rate" do
    test "2p FFA" do
      assert [
               [{29.230718726575056, 7.783287759506231}],
               [{20.769281273424944, 7.783287759506231}]
             ] == ThurstoneMostellerPart.rate([@team1, @team1])
    end

    test "3p FFA" do
      assert [
               [{29.230718726575056, 7.970854850411874}],
               [{25.0, 7.591087514198776}],
               [{20.769281273424944, 7.970854850411874}]
             ] == ThurstoneMostellerPart.rate([@team1, @team1, @team1])
    end

    test "4p FFA" do
      assert [
               [{29.230718726575056, 8.063002318979079}],
               [{25.0, 7.783287759506231}],
               [{25.0, 7.783287759506231}],
               [{20.769281273424944, 8.063002318979079}]
             ] == ThurstoneMostellerPart.rate([@team1, @team1, @team1, @team1])
    end

    test "5p FFA" do
      assert [
               [{29.230718726575056, 8.117788738663902}],
               [{25.0, 7.896362679532426}],
               [{25.0, 7.896362679532426}],
               [{25.0, 7.896362679532426}],
               [{20.769281273424944, 8.117788738663902}]
             ] == ThurstoneMostellerPart.rate([@team1, @team1, @team1, @team1, @team1])
    end

    test "3 teams different sized players" do
      assert [
               [
                 {25.029236237649556, 8.32682975257123},
                 {25.029236237649556, 8.32682975257123},
                 {25.029236237649556, 8.32682975257123}
               ],
               [{34.02513861155437, 7.978290956611053}],
               [{15.94562515079608, 7.985078415675121}, {15.94562515079608, 7.985078415675121}]
             ] == ThurstoneMostellerPart.rate([@team3, @team1, @team2])
    end

    test "1v1 win and then loss decreases mu" do
      alice1 = @r
      betty1 = @r
      [[alice2], [betty2]] = ThurstoneMostellerPart.rate([[alice1], [betty1]])
      [[alice3], [betty3]] = ThurstoneMostellerPart.rate([[betty2], [alice2]])

      assert [{26.97819106220699, 7.185640185216057}, {23.02180893779301, 7.185640185216057}] == [
               alice3,
               betty3
             ]
    end
  end
end
