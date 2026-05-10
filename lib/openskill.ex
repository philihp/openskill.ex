defmodule Openskill do
  @moduledoc """
    Openskill is a library for calculating skill ratings.
  """

  alias Openskill.{Environment, Util}

  @env %Environment{}

  @type mu() :: float()
  @type sigma() :: float()
  @type ordinal() :: float()
  @type mu_sigma_pair() :: {mu(), sigma()}
  @type mu_sigma_pair_with_id() :: {any, mu_sigma_pair()}

  @doc """
  Creates an initialized rating.

  ## Examples

      iex> Openskill.rating
      { 25, 8.333 }

      iex> Openskill.rating(1000, 32)
      { 1000, 32 }
  """
  @spec rating(mu() | nil, sigma() | nil) :: mu_sigma_pair()
  def rating(mu \\ nil, sigma \\ nil) do
    {mu || @env.mu, sigma || @env.sigma}
  end

  @spec ordinal(mu_sigma_pair()) :: ordinal()
  def ordinal({mu, sigma}) do
    mu - @env.z * sigma
  end

  @doc """
  Takes a list of ratings, first item is the winning team and second item is the losing team. Output is the same format as the input.
  [
    [
      {mu, sigma},
      {mu, sigma}
    ],
    [
      {mu, sigma},
      {mu, sigma}
    ]
  ]
  """
  @spec rate([[mu_sigma_pair()]], list()) :: [[mu_sigma_pair()]]
  def rate(rating_groups, options \\ []) do
    defaults = [
      weights: Util.default_weights(rating_groups),
      ranks: Util.default_ranks(rating_groups),
      model: Openskill.PlackettLuce
    ]

    options = Keyword.merge(defaults, options) |> Enum.into(%{})
    options.model.rate(rating_groups, options)
  end

  @doc """
  Same as rate but this time it expects each input to have an identifier as part of their tuple.

  [
    [
      {id, {mu, sigma}},
      {id, {mu, sigma}}
    ],
    [
      {id, {mu, sigma}},
      {id, {mu, sigma}}
    ]
  ]

  The result is in the same format as the input, just like `rate/2`
  [
    [
      {id, {mu, sigma}},
      {id, {mu, sigma}}
    ],
    [
      {id, {mu, sigma}},
      {id, {mu, sigma}}
    ]
  ]

  You can use the following to easily convert the results into a lookup:
    ```
    rating_groups
      |> Openskill.rate_with_ids
      |> List.flatten
      |> Map.new
    ```
  """
  @spec rate_with_ids([[mu_sigma_pair_with_id()]], list()) :: [[mu_sigma_pair_with_id()]]
  def rate_with_ids(rating_groups, options \\ []) do
    rating_groups_without_ids = rating_groups
      |> Enum.map(fn ratings_with_ids ->
        ratings_with_ids
          |> Enum.map(fn {_, rating} ->
            rating
          end)
      end)

    result = rate(rating_groups_without_ids, options)
      |> Enum.zip(rating_groups)
      |> Enum.map(fn {updated_values, original_values} ->
        original_values
          |> Enum.zip(updated_values)
          |> Enum.map(fn {{id, _}, updated_value} ->
            {id, updated_value}
          end)
      end)

    if options[:as_map] do
      result
        |> List.flatten
        |> Map.new
    else
      result
    end
  end

  @doc """
  Predict the win probability for each team. Returns a list of probabilities
  in the same order as the input teams; the values sum to 1.

  ## Examples

      iex> teams = [
      ...>   [{25, 8.333}, {30, 6.666}],
      ...>   [{27, 7.0}, {28, 5.5}]
      ...> ]
      iex> Openskill.predict_win(teams)
      [0.5000000005, 0.5000000005]

  When the sum of mu is equal across teams, the result is ~50% per team
  regardless of the sigmas. Increasing the mu of one team raises that team's
  predicted win probability; increasing the uncertainty of any team moves
  the result closer to 50%.
  """
  @spec predict_win([[mu_sigma_pair()]]) :: [float()]
  def predict_win(teams) do
    team_ratings = Util.team_rating(teams)
    n = length(teams)
    denom = n * (n - 1) / 2
    betasq = @env.beta * @env.beta

    team_ratings
    |> Enum.with_index()
    |> Enum.map(fn {{mu_a, sigma_sq_a, _team, _i}, i} ->
      sum =
        team_ratings
        |> Enum.with_index()
        |> Enum.filter(fn {_, q} -> i != q end)
        |> Enum.map(fn {{mu_b, sigma_sq_b, _team, _i}, _} ->
          Util.phi_major((mu_a - mu_b) / :math.sqrt(n * betasq + sigma_sq_a + sigma_sq_b))
        end)
        |> Enum.sum()

      sum / denom
    end)
  end
end
