defmodule Openskill.PlackettLuceTest do
  use ExUnit.Case
  alias Openskill.PlackettLuce

  @r Openskill.rating()
  @team1 [@r]
  @team2 [@r, @r]
  @team3 [@r, @r, @r]

  describe "#rate" do
    test "solo game does not change rating" do
      assert [@team1] == PlackettLuce.rate([@team1])
    end

    test "2p FFA" do
      assert [
               [{27.63523138347365, 8.065506316323548}],
               [{22.36476861652635, 8.065506316323548}]
             ] == PlackettLuce.rate([@team1, @team1])
    end

    test "3p FFA" do
      assert [
               [{27.868876552746237, 8.204837030780652}],
               [{25.717219138186557, 8.057829747583874}],
               [{21.413904309067206, 8.057829747583874}]
             ] == PlackettLuce.rate([@team1, @team1, @team1])
    end

    test "4p FFA" do
      assert [
               [{27.795084971874736, 8.263160757613477}],
               [{26.552824984374855, 8.179213704945203}],
               [{24.68943500312503, 8.083731307186588}],
               [{20.96265504062538, 8.083731307186588}]
             ] == PlackettLuce.rate([@team1, @team1, @team1, @team1])
    end

    test "5p FFA" do
      assert [
               [{27.666666666666668, 8.290556877154474}],
               [{26.833333333333332, 8.240145629781066}],
               [{25.72222222222222, 8.179996679645559}],
               [{24.055555555555557, 8.111796013701358}],
               [{20.72222222222222, 8.111796013701358}]
             ] == PlackettLuce.rate([@team1, @team1, @team1, @team1, @team1])
    end

    test "3 teams different sized players" do
      assert [
               [
                 {25.939870821784513, 8.247641552260456},
                 {25.939870821784513, 8.247641552260456},
                 {25.939870821784513, 8.247641552260456}
               ],
               [{27.21366020491262, 8.274321317985242}],
               [{21.84646897330287, 8.213058173195341}, {21.84646897330287, 8.213058173195341}]
             ] == PlackettLuce.rate([@team3, @team1, @team2])
    end

    test "1v1 win and then loss decreases mu" do
      alice1 = @r
      betty1 = @r
      [[alice2], [betty2]] = PlackettLuce.rate([[alice1], [betty1]])
      [[alice3], [betty3]] = PlackettLuce.rate([[betty2], [alice2]])

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
