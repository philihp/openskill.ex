defmodule Openskill.EnvironmentTest do
  use ExUnit.Case
  alias Openskill.Environment

  @env %Environment{}

  test "#mu" do
    assert is_number(%Environment{}.mu)
  end

  test "#sigma" do
    assert is_number(%Environment{}.sigma)
  end

  test "#beta" do
    assert is_number(%Environment{}.beta)
  end

  test "#epsilon" do
    assert is_number(%Environment{}.epsilon)
  end

  test "#z" do
    assert is_number(%Environment{}.z)
  end
end
