defmodule Openskill.ThurstoneMostellerPart do
  alias Openskill.{Environment, Util}

  @env %Environment{}
  @twobetasq 2 * @env.beta * @env.beta
  @epsilon 0.1

  def rate(game, _options \\ []) do
    team_ratings = Util.team_rating(game)
    adjacent_teams = Util.ladder_pairs(team_ratings)

    Enum.map(Enum.zip(team_ratings, adjacent_teams), fn {teami_rating, teami_adjacent} ->
      {teami_mu, teami_sigmasq, teami, ranki} = teami_rating

      {omegai, deltai} =
        teami_adjacent
        |> Enum.filter(fn {_, _, _, rankq} -> ranki != rankq end)
        |> Enum.reduce({0, 0}, fn {teamq_mu, teamq_sigmasq, _, rankq}, {omega, delta} ->
          ciq = Math.sqrt(teami_sigmasq + teamq_sigmasq + @twobetasq)
          tmp = (teami_mu - teamq_mu) / ciq
          sigsq_to_ciq = teami_sigmasq / ciq
          gamma = Math.sqrt(teami_sigmasq) / ciq

          cond do
            rankq > ranki ->
              {
                omega + sigsq_to_ciq * Util.v(tmp, @epsilon / ciq),
                delta + gamma * sigsq_to_ciq / ciq * Util.w(tmp, @epsilon / ciq)
              }

            rankq < ranki ->
              {
                omega + -sigsq_to_ciq * Util.v(-tmp, @epsilon / ciq),
                delta + gamma * sigsq_to_ciq / ciq * Util.w(-tmp, @epsilon / ciq)
              }

              # the filter above ensures that rankq and ranki are never the same,
              # however this would be necessary if supported tied rankings in 3+
              # team matches.
              #
              # true ->
              #   {
              #     omega + sigsq_to_ciq * Util.vt(tmp, @epsilon / ciq),
              #     delta + gamma * sigsq_to_ciq / ciq * Util.wt(tmp, @epsilon / ciq)
              #   }
          end
        end)

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
