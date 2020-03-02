defmodule Openskill.PlackettLuceTest do
  use ExUnit.Case
  alias Openskill.PlackettLuce

  @r Openskill.rating()
  @team1 [@r]
  @team2 [@r, @r]
  @team3 [@r, @r, @r]

  describe "#rate" do
    # test "solo game does not change rating" do
    #   assert [@team1] == PlackettLuce.rate([@team1])
    # end

    # test "2p FFA" do
    #   assert [
    #            [{25.0, 8.333333333333334}],
    #            [{24.5, 7.795119555779045}]
    #          ] ==
    #            PlackettLuce.rate([@team1, @team1])
    # end

    # test "3p FFA" do
    #   assert [
    #            [{25.0, 8.333333333333334}],
    #            [{24.5, 7.978559231302818}],
    #            [{24.166666666666668, 7.649403537897364}]
    #          ] == PlackettLuce.rate([@team1, @team1, @team1])
    # end

    test "4p FFA" do
      assert [
               [{27.79508, 8.26316}],
               [{26.55282, 8.17921}],
               [{24.68944, 8.08373}],
               [{20.96266, 8.08373}]
             ] == PlackettLuce.rate([@team1, @team1, @team1, @team1])
    end

    # test "5p FFA" do
    #   assert [
    #            [{25.0, 8.333333333333334}],
    #            [{24.5, 8.122328620674137}],
    #            [{24.166666666666668, 7.930056902011221}],
    #            [{23.916666666666668, 7.76412492187427}],
    #            [{23.71666666666667, 7.619672800077896}]
    #          ] == PlackettLuce.rate([@team1, @team1, @team1, @team1, @team1])
    # end

    # test "3 teams different sized players" do
    #   assert [
    #            [
    #              {25.0, 8.333333333333334},
    #              {25.0, 8.333333333333334},
    #              {25.0, 8.333333333333334}
    #            ],
    #            [
    #              {25.400679280763306, 7.8477171221025595}
    #            ],
    #            [
    #              {24.382489118588392, 8.66860837699982},
    #              {24.382489118588392, 8.66860837699982}
    #            ]
    #          ] == PlackettLuce.rate([@team3, @team1, @team2])
    # end

    # test "1v1 win and then loss decreases mu" do
    #   alice1 = @r
    #   betty1 = @r
    #   [[alice2], [betty2]] = PlackettLuce.rate([[alice1], [betty1]])
    #   [[alice3], [betty3]] = PlackettLuce.rate([[betty2], [alice2]])

    #   assert [
    #            {24.5, 7.795119555779045},
    #            {24.460299031966493, 7.886515246891691}
    #          ] == [
    #            alice3,
    #            betty3
    #          ]
    # end
  end
end
