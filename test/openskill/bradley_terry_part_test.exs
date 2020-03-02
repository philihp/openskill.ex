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
               [{27.63523138347365, 8.065506316323548}],
               [{22.36476861652635, 8.065506316323548}]
             ] ==
               BradleyTerryPart.rate([@team1, @team1])
    end

    test "3p FFA" do
      assert [
               [{27.63523138347365, 8.065506316323548}],
               [{25.0, 7.788474807872566}],
               [{22.36476861652635, 8.065506316323548}]
             ] == BradleyTerryPart.rate([@team1, @team1, @team1])
    end

    test "4p FFA" do
      assert [
               [{27.63523138347365, 8.065506316323548}],
               [{25.0, 7.788474807872566}],
               [{25.0, 7.788474807872566}],
               [{22.36476861652635, 8.065506316323548}]
             ] == BradleyTerryPart.rate([@team1, @team1, @team1, @team1])
    end

    test "5p FFA" do
      assert [
               [{27.63523138347365, 8.065506316323548}],
               [{25.0, 7.788474807872566}],
               [{25.0, 7.788474807872566}],
               [{25.0, 7.788474807872566}],
               [{22.36476861652635, 8.065506316323548}]
             ] == BradleyTerryPart.rate([@team1, @team1, @team1, @team1, @team1])
    end

    test "3 teams different sized players" do
      assert [
               [
                 {25.219231461891965, 8.293401112661954},
                 {25.219231461891965, 8.293401112661954},
                 {25.219231461891965, 8.293401112661954}
               ],
               [{28.48909130001799, 8.220848339985736}],
               [
                 {21.291677238090045, 8.206896387427937},
                 {21.291677238090045, 8.206896387427937}
               ]
             ] == BradleyTerryPart.rate([@team3, @team1, @team2])
    end

    test "1v1 win and then loss decreases mu" do
      alice1 = @r
      betty1 = @r
      [[alice2], [betty2]] = BradleyTerryPart.rate([[alice1], [betty1]])
      [[alice3], [betty3]] = BradleyTerryPart.rate([[betty2], [alice2]])

      assert [
               {25.4111001737357, 7.82210295723689},
               {24.5888998262643, 7.82210295723689}
             ] == [alice3, betty3]
    end
  end
end
