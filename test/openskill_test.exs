defmodule OpenskillTest do
  use ExUnit.Case
  @epsilon 0.001

  describe "#rating" do
    test "returns a default rating" do
      {mu, sigma} = Openskill.rating()
      assert mu == 25.0
      assert_in_delta sigma, 8.333, @epsilon
    end

    test "returns a rating with just mu initialized" do
      {mu, sigma} = Openskill.rating(100)
      assert mu == 100
      assert_in_delta sigma, 8.333, @epsilon
    end

    test "returns an initialized rating" do
      {mu, sigma} = Openskill.rating(1500, 32)
      assert mu == 1500
      assert sigma == 32
    end
  end

  describe "#ordinal" do
    test "accepts a gaussian, returns an ordinal" do
      assert 15 == Openskill.ordinal({30, 5})
    end

    test "default ordinal is 0" do
      assert 0 == Openskill.ordinal(Openskill.rating())
    end
  end

  describe "#rate" do
    test "rate accepts and runs a placket-luce model by default" do
      a1 = Openskill.rating(29.182, 4.782)
      b1 = Openskill.rating(27.174, 4.922)
      c1 = Openskill.rating(16.672, 6.217)
      d1 = Openskill.rating()

      [[a2], [b2], [c2], [d2]] = Openskill.rate([[a1], [b1], [c1], [d1]], tau: 0)

      assert [
               [{30.209971908310553, 4.764898977359521}],
               [{27.64460833689499, 4.882789305097372}],
               [{17.403586731283518, 6.100723440599442}],
               [{19.214790707434826, 7.8542613981643985}]
             ] == [[a2], [b2], [c2], [d2]]
    end

    test "accepts bradley-terry with full pairings" do
      a1 = Openskill.rating(29.182, 4.782)
      b1 = Openskill.rating(27.174, 4.922)
      c1 = Openskill.rating(16.672, 6.217)
      d1 = Openskill.rating()

      [[a2], [b2], [c2], [d2]] =
        Openskill.rate(
          [[a1], [b1], [c1], [d1]],
          model: Openskill.BradleyTerryFull,
          tau: 0
        )

      assert [
               [{31.643721109067318, 4.5999011726035866}],
               [{27.579203181313282, 4.711537319421646}],
               [{16.96606210683349, 5.824625458553909}],
               [{15.834345097607386, 7.1129977453618745}]
             ] == [[a2], [b2], [c2], [d2]]
    end

    test "accepts thurstone mosteller with part pairings" do
      a1 = Openskill.rating(29.182, 4.782)
      b1 = Openskill.rating(27.174, 4.922)
      c1 = Openskill.rating(16.672, 6.217)
      d1 = Openskill.rating()

      [[a2], [b2], [c2], [d2]] =
        Openskill.rate(
          [[a1], [b1], [c1], [d1]],
          model: Openskill.ThurstoneMostellerPart,
          tau: 0
        )

      assert [
               [{30.872374450270552, 4.56949895985143}],
               [{26.041422654098124, 4.568136168196902}],
               [{19.808527703340072, 5.575297670506283}],
               [{17.47779366561652, 7.175216992011798}]
             ] == [[a2], [b2], [c2], [d2]]
    end
  end

  describe "#rate_with_ids" do
    test "rate_with_ids accepts returns ids next to values" do
      # The algorithm is already tested, we are instead testing the formatting
      # of this wrapper function
      a1 = {"a1", Openskill.rating(29.182, 4.782)}
      b1 = {"b1", Openskill.rating(27.174, 4.922)}
      c1 = {"c1", Openskill.rating(16.672, 6.217)}
      d1 = {"d1", Openskill.rating()}

      result = Openskill.rate_with_ids([[a1], [b1], [c1], [d1]])

      assert match?([
        [{"a1", {_, _}}],
        [{"b1", {_, _}}],
        [{"c1", {_, _}}],
        [{"d1", {_, _}}]
      ], result)

      # Ensure the format of the result is correct in a 2v2 situation too
      result = Openskill.rate_with_ids([[a1, b1], [c1, d1]])

      assert match?([
        [{"a1", {_, _}}, {"b1", {_, _}}],
        [{"c1", {_, _}}, {"d1", {_, _}}]
      ], result)

      # Now ensure it adheres to the :as_map option
      result = Openskill.rate_with_ids([[a1, b1], [c1, d1]], as_map: true)

      assert match?(%{
        "a1" => {_, _},
        "b1" => {_, _},
        "c1" => {_, _},
        "d1" => {_, _}
      }, result)
    end
  end

  describe "#predict_win" do
    test "equal team mu sums give equal win probability regardless of sigmas" do
      teams = [
        [{25, 8.333}, {30, 6.666}],
        [{27, 7.0}, {28, 5.5}]
      ]

      assert [0.5000000005, 0.5000000005] = Openskill.predict_win(teams)
    end

    test "matches openskill.py reference output" do
      # https://github.com/vivekjoshy/openskill.py/blob/main/docs/source/manual.rst#predicting-winners
      teams = [
        [{25, 25 / 3}],
        [{33.564, 1.123}]
      ]

      assert [0.202122560771339, 0.797877439228661] = Openskill.predict_win(teams)
    end

    test "raising one team's mu raises that team's win probability" do
      [equal_a, _equal_b] =
        Openskill.predict_win([
          [{50, 1}, {0, 6.666}],
          [{25, 1}, {25, 5.5}]
        ])

      [advantaged_a, _disadvantaged_b] =
        Openskill.predict_win([
          [{50, 1}, {1, 6.666}],
          [{25, 1}, {25, 5.5}]
        ])

      assert advantaged_a > equal_a
    end

    test "raising sigma on either side moves probability toward 50%" do
      [base_a, _base_b] =
        Openskill.predict_win([
          [{50, 1}, {1, 6.666}],
          [{25, 1}, {25, 5.5}]
        ])

      [noisier_a, _] =
        Openskill.predict_win([
          [{50, 8}, {1, 6.666}],
          [{25, 1}, {25, 5.5}]
        ])

      assert abs(noisier_a - 0.5) < abs(base_a - 0.5)
    end

    test "probabilities sum to 1" do
      teams = [
        [{25, 8.333}],
        [{30, 6.666}],
        [{27, 7.0}]
      ]

      probabilities = Openskill.predict_win(teams)
      assert_in_delta Enum.sum(probabilities), 1.0, 1.0e-9
    end
  end

  describe "#rate Plackett-Luce parity with openskill.js" do
    # Reference values are produced by openskill.js v6.x which itself is
    # bit-for-bit aligned with openskill.py 6.x. Both expected outputs
    # below were generated with the openskill.js default tau (25/300).

    test "doubles match" do
      inputs = [
        [{29.182, 4.782}, {27.174, 4.922}],
        [{16.672, 6.217}, {25.0, 25 / 3}]
      ]

      assert [
               [
                 {29.607340941337068, 4.755311788972862},
                 {27.624602782532037, 4.892807828777459}
               ],
               [
                 {15.953170429143093, 6.125902065139878},
                 {23.70858117648013, 8.111707446126035}
               ]
             ] == Openskill.rate(inputs, tau: 25 / 300)
    end

    test "four-way free-for-all" do
      inputs = [
        [{29.182, 4.782}],
        [{27.174, 4.922}],
        [{16.672, 6.217}],
        [{25.0, 25 / 3}]
      ]

      assert [
               [{30.210227447000438, 4.765617924939384}],
               [{27.644725221915632, 4.883479590134575}],
               [{17.4036218889969, 6.101259408259549}],
               [{19.21460876538932, 7.854669920480409}]
             ] == Openskill.rate(inputs, tau: 25 / 300)
    end
  end

  describe "#rate with tau" do
    test "default tau adds noise to sigma before rating" do
      a1 = Openskill.rating(29.182, 4.782)
      b1 = Openskill.rating(27.174, 4.922)
      c1 = Openskill.rating(16.672, 6.217)
      d1 = Openskill.rating()

      [[a2], [b2], [c2], [d2]] = Openskill.rate([[a1], [b1], [c1], [d1]], tau: 0.01)

      assert [
               [{30.20997558824299, 4.764909330988368}],
               [{27.64461002009721, 4.882799245921361}],
               [{17.403587237635527, 6.100731158882956}],
               [{19.21478808745494, 7.854267281042293}]
             ] == [[a2], [b2], [c2], [d2]]
    end

    test "prevent_sigma_increase clamps post-rate sigma to be no larger than pre-rate sigma" do
      a1 = Openskill.rating(6.672, 0.0001)
      b1 = Openskill.rating(29.182, 4.782)

      [[a2], [_b2]] = Openskill.rate([[a1], [b1]], tau: 0.01, prevent_sigma_increase: true)

      {_a1_mu, a1_sigma} = a1
      {_a2_mu, a2_sigma} = a2

      assert a2_sigma <= a1_sigma
    end
  end
end
