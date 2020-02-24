defmodule Openskill.RatingTest do
  alias Openskill.{Environment, Rating}
  use ExUnit.Case

  @env %Environment{}

  describe "#create_rating" do
    test "returns a rating" do
      assert %Rating{} = Rating.new(@env)
    end

    test "first param sets mu" do
      assert %Rating{mu: 100} = Rating.new(100, @env)
    end

    test "second param sets sigma" do
      assert %Rating{mu: 100, sigma: 20} = Rating.new(100, 20, @env)
    end
  end
end
