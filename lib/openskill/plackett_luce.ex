defmodule Openskill.PlackettLuce do
  alias Openskill.{Environment, Util}

  @env %Environment{}
  @betasq @env.beta * @env.beta
  @kappa @env.epsilon

  def rate(game, _options \\ []) do
    team_ratings = Util.team_rating(game)

    c =
      team_ratings
      |> Enum.map(fn {_, team_sigmasq, _, _} -> team_sigmasq + @betasq end)
      |> Enum.sum()
      |> Math.sqrt()

    sum_q =
      Enum.map(team_ratings, fn {_, _, _, q_rank} ->
        team_ratings
        |> Enum.filter(fn {_, _, _, i_rank} -> i_rank >= q_rank end)
        |> Enum.map(fn {i_mu, _, _, _} -> Math.exp(i_mu / c) end)
        |> Enum.sum()
      end)

    a =
      Enum.map(team_ratings, fn {_, _, _, q_rank} ->
        Enum.count(team_ratings, fn {_, _, _, i_rank} -> i_rank == q_rank end)
      end)

    indexed_q =
      team_ratings
      |> Enum.zip(sum_q)
      |> Enum.zip(a)
      |> Enum.with_index()
      |> Enum.map(fn {{{tr, sum_q_q}, a_q}, q} -> {tr, sum_q_q, a_q, q} end)

    team_ratings
    |> Enum.with_index()
    |> Enum.map(fn {{i_mu, i_sigmasq, i_team, i_rank}, i} ->
      i_mu_over_ce = Math.exp(i_mu / c)

      {omega_sum, delta_sum} =
        Enum.reduce(indexed_q, {0, 0}, fn {{_, _, _, q_rank}, sum_q_q, a_q, q}, {omega, delta} ->
          if q_rank > i_rank do
            {omega, delta}
          else
            quotient = i_mu_over_ce / sum_q_q
            term = if i == q, do: 1 - quotient, else: -quotient
            {omega + term / a_q, delta + quotient * (1 - quotient) / a_q}
          end
        end)

      i_gamma = Math.sqrt(i_sigmasq) / c
      i_omega = omega_sum * (i_sigmasq / c)
      i_delta = delta_sum * (i_sigmasq / (c * c)) * i_gamma

      for {mu, sigma} <- i_team do
        sigma_sq = sigma * sigma

        {
          mu + sigma_sq / i_sigmasq * i_omega,
          sigma * Math.sqrt(max(1 - sigma_sq / i_sigmasq * i_delta, @kappa))
        }
      end
    end)
  end
end
