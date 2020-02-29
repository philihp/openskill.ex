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
               [{29.230718863453703, 7.783287722480908}],
               [{20.769281136546297, 7.783287722480908}]
             ] == ThurstoneMostellerPart.rate([@team1, @team1])
    end

    test "3p FFA" do
      assert [
               [{29.230718863453703, 7.97085482630917}],
               [{25.0, 7.591087463581743}],
               [{20.769281136546297, 7.97085482630917}]
             ] == ThurstoneMostellerPart.rate([@team1, @team1, @team1])
    end

    test "4p FFA" do
      assert [
               [{29.230718863453703, 8.063002301108641}],
               [{25.0, 7.783287722480908}],
               [{25.0, 7.783287722480908}],
               [{20.769281136546297, 8.063002301108641}]
             ] == ThurstoneMostellerPart.rate([@team1, @team1, @team1, @team1])
    end

    test "5p FFA" do
      assert [
               [{29.230718863453703, 8.11778872446404}],
               [{25.0, 7.896362650336325}],
               [{25.0, 7.896362650336325}],
               [{25.0, 7.896362650336325}],
               [{20.769281136546297, 8.11778872446404}]
             ] == ThurstoneMostellerPart.rate([@team1, @team1, @team1, @team1, @team1])
    end

    test "3 teams different sized players" do
      assert [
               [
                 {25.029236239474983, 8.326829752163938},
                 {25.029236239474983, 8.326829752163938},
                 {25.029236239474983, 8.326829752163938}
               ],
               [{34.02513900808649, 7.9782908651688835}],
               [{15.945624752438526, 7.985078324735403}, {15.945624752438526, 7.985078324735403}]
             ] == ThurstoneMostellerPart.rate([@team3, @team1, @team2])
    end

    test "1v1 win and then loss decreases mu" do
      alice1 = @r
      betty1 = @r
      [[alice2], [betty2]] = ThurstoneMostellerPart.rate([[alice1], [betty1]])
      [[alice3], [betty3]] = ThurstoneMostellerPart.rate([[betty2], [alice2]])

      assert [{26.9781922603812, 7.185639744322998}, {23.0218077396188, 7.185639744322998}] == [
               alice3,
               betty3
             ]
    end
  end
end
