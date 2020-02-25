defmodule Openskill.Util do
  def score(q, i) do
    cond do
      q < i -> 0.0
      q == i -> 0.5
      q > i -> 1.0
    end
  end

  def team_rating(game) do
    game
    |> Enum.with_index(1)
    |> Enum.map(fn {team, i} ->
      {
        team |> Enum.map(fn {mu, _sigma} -> mu end) |> Enum.sum(),
        team |> Enum.map(fn {_mu, sigma} -> sigma * sigma end) |> Enum.sum(),
        team,
        i
      }
    end)
  end

  def default_weights([]) do
    []
  end

  def default_weights([team | teams]) do
    team_weights = for _i <- team, do: 1
    [team_weights | default_weights(teams)]
  end

  def default_ranks(teams, count \\ 1)

  def default_ranks([], _count) do
    []
  end

  def default_ranks([_ | teams], count) do
    [count | default_ranks(teams, count + 1)]
  end
end
