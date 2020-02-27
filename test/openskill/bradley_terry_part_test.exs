defmodule Openskill.BradleyTerryPartTest do
  use ExUnit.Case
  alias Openskill.BradleyTerryPart

  # @r Openskill.rating()
  # @team1 [@r]
  # @team2 [@r, @r]
  # @team3 [@r, @r, @r]

  describe "#rate" do
    # test "solo game does not change rating" do
    #   assert [@team1] == BradleyTerryPart.rate([@team1])
    # end

    # test "2p FFA" do
    #   assert [
    #            [{27.63523138347365, 7.905694150420949}],
    #            [{22.36476861652635, 7.905694150420949}]
    #          ] == BradleyTerryPart.rate([@team1, @team1])
    # end

    # test "3p FFA" do
    #   assert [
    #            [{30.2704627669473, 7.4535599249993}],
    #            [{25.0, 7.4535599249993}],
    #            [{19.7295372330527, 7.4535599249993}]
    #          ] == BradleyTerryPart.rate([@team1, @team1, @team1])
    # end

    # test "4p FFA" do
    #   assert [
    #            [{32.90569415042095, 6.972166887783963}],
    #            [{27.63523138347365, 6.972166887783963}],
    #            [{22.36476861652635, 6.972166887783963}],
    #            [{17.09430584957905, 6.972166887783963}]
    #          ] == BradleyTerryPart.rate([@team1, @team1, @team1, @team1])
    # end

    # test "5p FFA" do
    #   assert [
    #            [{35.5409255338946, 6.454972243679028}],
    #            [{30.2704627669473, 6.454972243679028}],
    #            [{25.0, 6.454972243679028}],
    #            [{19.729537233052703, 6.454972243679028}],
    #            [{14.4590744661054, 6.454972243679028}]
    #          ] == BradleyTerryPart.rate([@team1, @team1, @team1, @team1, @team1])
    # end

    # test "3 teams different sized players" do
    #   assert [
    #            [
    #              {25.992743915179297, 8.153591175421319},
    #              {25.992743915179297, 8.153591175421319},
    #              {25.992743915179297, 8.153591175421319}
    #            ],
    #            [{28.48909130001799, 8.11571066636775}],
    #            [
    #              {20.518164784802718, 8.0329125727317},
    #              {20.518164784802718, 8.0329125727317}
    #            ]
    #          ] == BradleyTerryPart.rate([@team3, @team1, @team2])
    # end

    # test "1v1 win and then loss decreases mu" do
    #   alice1 = @r
    #   betty1 = @r
    #   [[alice2], [betty2]] = BradleyTerryPart.rate([[alice1], [betty1]])
    #   [[alice3], [betty3]] = BradleyTerryPart.rate([[betty2], [alice2]])

    #   assert [
    #            {25.345689545684444, 7.526232901340166},
    #            {24.654310454315556, 7.526232901340166}
    #          ] == [alice3, betty3]
    # end
  end
end
