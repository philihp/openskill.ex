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
               [{29.230718863453703, 7.6309346648043945}],
               [{20.769281136546297, 7.6309346648043945}]
             ] == ThurstoneMostellerPart.rate([@team1, @team1])
    end

    test "3p FFA" do
      assert [
               [{29.230718863453703, 7.6309346648043945}],
               [{25.0, 6.8569587480589576}],
               [{20.769281136546297, 7.6309346648043945}]
             ] == ThurstoneMostellerPart.rate([@team1, @team1, @team1])
    end

    test "4p FFA" do
      assert [
               [{29.230718863453703, 7.6309346648043945}],
               [{25.0, 6.8569587480589576}],
               [{25.0, 6.8569587480589576}],
               [{20.769281136546297, 7.6309346648043945}]
             ] == ThurstoneMostellerPart.rate([@team1, @team1, @team1, @team1])
    end

    test "5p FFA" do
      assert [
               [{29.230718863453703, 7.6309346648043945}],
               [{25.0, 6.8569587480589576}],
               [{25.0, 6.8569587480589576}],
               [{25.0, 6.8569587480589576}],
               [{20.769281136546297, 7.6309346648043945}]
             ] == ThurstoneMostellerPart.rate([@team1, @team1, @team1, @team1, @team1])
    end

    test "3 teams different sized players" do
      assert [
               [
                 {25.029236239474983, 8.317393850240839},
                 {25.029236239474983, 8.317393850240839},
                 {25.029236239474983, 8.317393850240839}
               ],
               [{34.02513900808649, 7.7574602751322255}],
               [
                 {15.945624752438526, 7.520417745695902},
                 {15.945624752438526, 7.520417745695902}
               ]
             ] == ThurstoneMostellerPart.rate([@team3, @team1, @team2])
    end

    test "1v1 win and then loss decreases mu" do
      alice1 = @r
      betty1 = @r
      [[alice2], [betty2]] = ThurstoneMostellerPart.rate([[alice1], [betty1]])
      [[alice3], [betty3]] = ThurstoneMostellerPart.rate([[betty2], [alice2]])

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
