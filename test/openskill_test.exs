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

      [[a2], [b2], [c2], [d2]] = Openskill.rate([[a1], [b1], [c1], [d1]])

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
          model: Openskill.BradleyTerryFull
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
          model: Openskill.ThurstoneMostellerPart
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
end
