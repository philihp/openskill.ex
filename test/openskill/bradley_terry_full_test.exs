defmodule Openskill.BradleyTerryFullTest do
  use ExUnit.Case
  alias Openskill.BradleyTerryFull

  @r Openskill.rating()
  @team1 [@r]
  @team2 [@r, @r]
  @team3 [@r, @r, @r]

  describe "#rate" do
    test "solo game does not change rating" do
      assert [@team1] == BradleyTerryFull.rate([@team1])
    end

    test "2p FFA" do
      assert [
               [{27.63523138347365, 8.065506316323548}],
               [{22.36476861652635, 8.065506316323548}]
             ] == BradleyTerryFull.rate([@team1, @team1])
    end

    test "3p FFA" do
      assert [
               [{30.2704627669473, 7.788474807872566}],
               [{25.0, 7.788474807872566}],
               [{19.7295372330527, 7.788474807872566}]
             ] == BradleyTerryFull.rate([@team1, @team1, @team1])
    end

    test "4p FFA" do
      assert [
               [{32.90569415042095, 7.5012190693964005}],
               [{27.63523138347365, 7.5012190693964005}],
               [{22.36476861652635, 7.5012190693964005}],
               [{17.09430584957905, 7.5012190693964005}]
             ] == BradleyTerryFull.rate([@team1, @team1, @team1, @team1])
    end

    test "5p FFA" do
      assert [
               [{35.5409255338946, 7.202515895247076}],
               [{30.2704627669473, 7.202515895247076}],
               [{25.0, 7.202515895247076}],
               [{19.729537233052703, 7.202515895247076}],
               [{14.4590744661054, 7.202515895247076}]
             ] == BradleyTerryFull.rate([@team1, @team1, @team1, @team1, @team1])
    end

    test "3 teams different sized players" do
      assert [
               [
                 {25.992743915179297, 8.19709997489984},
                 {25.992743915179297, 8.19709997489984},
                 {25.992743915179297, 8.19709997489984}
               ],
               [{28.48909130001799, 8.220848339985736}],
               [
                 {20.518164784802718, 8.127515465304823},
                 {20.518164784802718, 8.127515465304823}
               ]
             ] == BradleyTerryFull.rate([@team3, @team1, @team2])
    end

    test "1v1 win and then loss decreases mu" do
      alice1 = @r
      betty1 = @r
      [[alice2], [betty2]] = BradleyTerryFull.rate([[alice1], [betty1]])
      [[alice3], [betty3]] = BradleyTerryFull.rate([[betty2], [alice2]])

      assert [
               {25.4111001737357, 7.82210295723689},
               {24.5888998262643, 7.82210295723689}
             ] == [
               alice3,
               betty3
             ]
    end
  end
end
