defmodule Openskill.BradleyTerryPartTest do
  use ExUnit.Case
  alias Openskill.BradleyTerryPart

  @r Openskill.rating()
  @team1 [@r]
  @team2 [@r, @r]
  @team3 [@r, @r, @r]

  describe "#rate" do
    test "2p FFA" do
      assert [
               [{27.63523138347365, 7.905694150420949}],
               [{22.36476861652635, 7.905694150420949}]
             ] == BradleyTerryPart.rate([@team1, @team1])
    end

    test "3p FFA" do
      assert [
               [{27.63523138347365, 7.905694150420949}],
               [{25.0, 7.4535599249993}],
               [{22.36476861652635, 7.905694150420949}]
             ] == BradleyTerryPart.rate([@team1, @team1, @team1])
    end

    test "4p FFA" do
      assert [
               [{27.63523138347365, 7.905694150420949}],
               [{25.0, 7.4535599249993}],
               [{25.0, 7.4535599249993}],
               [{22.36476861652635, 7.905694150420949}]
             ] == BradleyTerryPart.rate([@team1, @team1, @team1, @team1])
    end

    test "5p FFA" do
      assert [
               [{27.63523138347365, 7.905694150420949}],
               [{25.0, 7.4535599249993}],
               [{25.0, 7.4535599249993}],
               [{25.0, 7.4535599249993}],
               [{22.36476861652635, 7.905694150420949}]
             ] == BradleyTerryPart.rate([@team1, @team1, @team1, @team1, @team1])
    end

    test "3 teams different sized players" do
      assert [
               [
                 {25.219231461891965, 8.284400060336209},
                 {25.219231461891965, 8.284400060336209},
                 {25.219231461891965, 8.284400060336209}
               ],
               [{28.48909130001799, 8.11571066636775}],
               [
                 {21.291677238090045, 8.165654885245957},
                 {21.291677238090045, 8.165654885245957}
               ]
             ] == BradleyTerryPart.rate([@team3, @team1, @team2])
    end

    test "1v1 win and then loss decreases mu" do
      alice1 = @r
      betty1 = @r
      [[alice2], [betty2]] = BradleyTerryPart.rate([[alice1], [betty1]])
      [[alice3], [betty3]] = BradleyTerryPart.rate([[betty2], [alice2]])

      assert [
               {25.345689545684444, 7.526232901340166},
               {24.654310454315556, 7.526232901340166}
             ] == [alice3, betty3]
    end
  end
end
