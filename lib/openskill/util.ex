defmodule Openskill.Util do
  def team_rating(game) do
    Enum.map(game, fn team ->
      {
        team |> Enum.map(fn {mu, _sigma} -> mu end) |> Enum.sum(),
        team |> Enum.map(fn {_mu, sigma} -> sigma * sigma end) |> Enum.sum()
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
