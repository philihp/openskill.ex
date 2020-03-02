defmodule Openskill.PlackettLuce do
  alias Openskill.{Environment, Util}

  @env %Environment{}
  @betasq @env.beta * @env.beta

  def rate(game, _options \\ []) do
    team_ratings = Util.team_rating(game)
    gamma = 1 / Enum.count(game)

    c =
      Enum.map(team_ratings, fn {_, team_sigmasq, _, _} ->
        team_sigmasq + @betasq
      end)
      |> Enum.sum()
      |> Math.sqrt()
      |> IO.inspect(label: :c)

    sum_q =
      team_ratings
      |> Enum.map(fn {_, _, _, teamq_rank} ->
        team_ratings
        |> Enum.filter(fn {_, _, _, teami_rank} -> teami_rank >= teamq_rank end)
        |> Enum.map(fn {teami_mu, _, _, _} ->
          Math.exp(teami_mu / c)
        end)
        |> Enum.sum()
      end)
      |> Enum.with_index(1)
      |> Enum.map(fn {k, v} -> {v, k} end)
      |> Map.new()
      |> IO.inspect(label: :sum_q)

    a =
      team_ratings
      |> Enum.map(fn {_, _, _, teami_rank} ->
        team_ratings
        |> Enum.filter(fn {_, _, _, teamq_rank} -> teami_rank == teamq_rank end)
        |> Enum.count()
      end)
      |> Enum.with_index(1)
      |> Enum.map(fn {k, v} -> {v, k} end)
      |> Map.new()

    team_ratings
    |> Enum.map(fn {teami_mu, teami_sigmasq, teami, teami_rank} ->
      tmp1 = Math.exp(teami_mu / c)

      {omega_set, delta_set} =
        team_ratings
        |> Enum.filter(fn {_, _, _, teamq_rank} -> teamq_rank <= teami_rank end)
        |> Enum.map(fn {_, _, _, teamq_rank} ->
          tmp = tmp1 / sum_q[teamq_rank]

          {
            if teamq_rank == teami_rank do
              1 - tmp / a[teamq_rank]
            else
              -tmp / a[teamq_rank]
            end,
            tmp * (1 - tmp) / a[teamq_rank]
          }
        end)
        |> Enum.unzip()

      IO.inspect(omega_set, label: :omega_set)
      IO.inspect(delta_set, label: :delta_set)

      omegai =
        (Enum.sum(omega_set) * teami_sigmasq / c)
        |> IO.inspect(label: :omegai)

      deltai =
        (Enum.sum(delta_set) * teami_sigmasq / c / c * gamma)
        |> IO.inspect(label: :deltai)

      for {muij, sigmaij} <- teami do
        sigmaijsq = sigmaij * sigmaij

        {
          muij + sigmaijsq / teami_sigmasq * omegai,
          sigmaij * Math.sqrt(max(1 - sigmaijsq / teami_sigmasq * deltai, @env.epsilon))
        }
      end
    end)
  end
end
