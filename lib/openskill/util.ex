defmodule Openskill.Util do
  @min_value 2.222758749e-162

  def score(q, i) do
    cond do
      q < i -> 0.0
      q == i -> 0.5
      q > i -> 1.0
    end
  end

  def ladder_pairs(ranks) do
    size = Enum.count(ranks)
    left = [nil] ++ Enum.take(ranks, size - 1)
    right = Enum.take(ranks, 1 - size) ++ [nil]

    Enum.zip(left, right)
    |> Enum.map(fn q ->
      case q do
        {left, nil} -> [left]
        {nil, right} -> [right]
        {left, right} -> [left, right]
      end
    end)
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

  def phi_minor(x) do
    Statistics.Distributions.Normal.pdf().(x)
  end

  def phi_major(x) do
    Statistics.Distributions.Normal.cdf().(x)
  end

  def v(x, t) do
    xt = x - t
    denom = phi_major(x - t)

    if denom < @min_value do
      -xt
    else
      phi_minor(xt) / denom
    end
  end

  def w(x, t) do
    xt = x - t
    denom = phi_major(xt)

    if(denom < @min_value) do
      if(x < 0) do
        1
      else
        0
      end
    else
      v(x, t) * (v(x, t) + xt)
    end
  end

  def vt(x, t) do
    xx = abs(x)
    b = phi_major(t - xx) - phi_major(-t - xx)

    if b < 0.00001 do
      if(x < 0) do
        -x - t
      else
        -x + t
      end
    else
      a = phi_minor(-t - xx) - phi_minor(t - xx)

      if x < 0 do
        -a / b
      else
        a / b
      end
    end
  end

  def wt(x, t) do
    xx = abs(x)
    b = phi_major(t - xx) - phi_major(-t - xx)

    if(b < @min_value) do
      1.0
    else
      ((t - xx) * phi_minor(t - xx) + (t + xx) * phi_minor(-t - xx)) / b + vt(x, t) * vt(x, t)
    end
  end
end
