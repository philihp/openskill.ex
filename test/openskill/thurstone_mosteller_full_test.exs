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
               [{29.230718863453703, 7.6309346648043945}],
               [{20.769281136546297, 7.6309346648043945}]
             ] == ThurstoneMostellerFull.rate([@team1, @team1])
    end

    test "3p FFA" do
      assert [
               [{33.461437726907405, 6.8569587480589576}],
               [{25.0, 6.8569587480589576}],
               [{16.538562273092595, 6.8569587480589576}]
             ] == ThurstoneMostellerFull.rate([@team1, @team1, @team1])
    end

    test "4p FFA" do
      assert [
               [{37.69215659036111, 5.983694735416504}],
               [{29.230718863453703, 5.983694735416504}],
               [{20.769281136546297, 5.983694735416504}],
               [{12.307843409638892, 5.983694735416504}]
             ] == ThurstoneMostellerFull.rate([@team1, @team1, @team1, @team1])
    end

    test "5p FFA" do
      assert [
               [{41.92287545381481, 4.958963813209379}],
               [{33.461437726907405, 4.958963813209379}],
               [{25.0, 4.958963813209379}],
               [{16.538562273092595, 4.958963813209379}],
               [{8.077124546185189, 4.958963813209379}]
             ] == ThurstoneMostellerFull.rate([@team1, @team1, @team1, @team1, @team1])
    end

    test "3 teams different sized players" do
      assert [
               [
                 {25.729796856853458, 8.15316922099208},
                 {25.729796856853458, 8.15316922099208},
                 {25.729796856853458, 8.15316922099208}
               ],
               [{34.02513900808649, 7.7574602751322255}],
               [
                 {15.245064135060051, 7.372120742156807},
                 {15.245064135060051, 7.372120742156807}
               ]
             ] == ThurstoneMostellerFull.rate([@team3, @team1, @team2])
    end

    test "1v1 win and then loss decreases mu" do
      alice1 = @r
      betty1 = @r
      [[alice2], [betty2]] = ThurstoneMostellerFull.rate([[alice1], [betty1]])
      [[alice3], [betty3]] = ThurstoneMostellerFull.rate([[betty2], [alice2]])

      assert [
               {26.867579929722677, 6.901538656723761},
               {23.132420070277323, 6.901538656723761}
             ] == [
               alice3,
               betty3
             ]
    end
  end
end
