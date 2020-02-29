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
               [{29.230718863453703, 7.783287722480908}],
               [{20.769281136546297, 7.783287722480908}]
             ] == ThurstoneMostellerFull.rate([@team1, @team1])
    end

    test "3p FFA" do
      assert [
               [{33.461437726907405, 7.591087463581743}],
               [{25.0, 7.591087463581743}],
               [{16.538562273092595, 7.591087463581743}]
             ] == ThurstoneMostellerFull.rate([@team1, @team1, @team1])
    end

    test "4p FFA" do
      assert [
               [{37.69215659036111, 7.493138823894886}],
               [{29.230718863453703, 7.493138823894886}],
               [{20.769281136546297, 7.493138823894886}],
               [{12.307843409638892, 7.493138823894886}]
             ] == ThurstoneMostellerFull.rate([@team1, @team1, @team1, @team1])
    end

    test "5p FFA" do
      assert [
               [{41.92287545381481, 7.433750181893967}],
               [{33.461437726907405, 7.433750181893967}],
               [{25.0, 7.433750181893967}],
               [{16.538562273092595, 7.433750181893967}],
               [{8.077124546185189, 7.433750181893967}]
             ] == ThurstoneMostellerFull.rate([@team1, @team1, @team1, @team1, @team1])
    end

    test "3 teams different sized players" do
      assert [
               [
                 {25.729796856853458, 8.253198713409791},
                 {25.729796856853458, 8.253198713409791},
                 {25.729796856853458, 8.253198713409791}
               ],
               [{34.02513900808649, 7.9782908651688835}],
               [{15.245064135060051, 7.90826600043686}, {15.245064135060051, 7.90826600043686}]
             ] == ThurstoneMostellerFull.rate([@team3, @team1, @team2])
    end

    test "1v1 win and then loss decreases mu" do
      alice1 = @r
      betty1 = @r
      [[alice2], [betty2]] = ThurstoneMostellerFull.rate([[alice1], [betty1]])
      [[alice3], [betty3]] = ThurstoneMostellerFull.rate([[betty2], [alice2]])

      assert [{26.9781922603812, 7.185639744322998}, {23.0218077396188, 7.185639744322998}] == [
               alice3,
               betty3
             ]
    end
  end
end
