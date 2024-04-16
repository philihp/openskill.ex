[![Hex.pm](https://img.shields.io/hexpm/v/openskill)](https://hex.pm/packages/openskill)
![Test Status](https://github.com/philihp/openskill.ex/workflows/tests/badge.svg?branch=master)
[![Coverage Status](https://coveralls.io/repos/github/philihp/openskill.ex/badge.svg?branch=master)](https://coveralls.io/github/philihp/openskill.ex?branch=master)
![Hex Downloads](https://img.shields.io/hexpm/dt/openskill)
[![Renovate Status](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com)

# Openskill

Elixir implementation of Weng-Lin Rating, as described at https://www.csie.ntu.edu.tw/~cjlin/papers/online_ranking/online_journal.pdf

## Installation

Add `openskill` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:openskill, "~> 1.0"}
  ]
end
```

## Usage

Ratings are kept as a tuple `{mu, sigma}` which represent a gaussian curve, where `mu` represents the _mean_, and `sigma` represents the spread or standard deviation. Create these with:

```elixir
> a1 = Openskill.rating
{25, 8.333333333333334}
> a2 = Openskill.rating(32.444, 5.123)
{32.444, 5.123}
> b1 = Openskill.rating(43.381, 2.421)
{43.381, 2.421}
> b2 = Openskill.rating(25.188, 6.211)
{25.188, 6.211}
```

If `a1` and `a2` are on a team, and wins against a team of `b1` and `b2`, send this into `rank`

```elixir
> [[a1, a2], [b1, b2]] = Openskill.rate([[a1, a2], [b1, b2]])
[
  [
    {28.669648436582808, 8.071520788025197},
    {33.83086971107981, 5.062772998705765}
  ],
  [
    {43.071274808241974, 2.4166900452721256},
    {23.149503312339064, 6.1378606973362135}
  ]
]
```

In more simplified matches with one team against another, the losing team's players' `mu` components should always go down, and up for the winning team's players. `sigma` components should always go down.

### Extended usage
You can use `Openskill.rate_with_ids` to place an identifier next to each rating and preserve that identifier in the result.
```elixir
> [[a1, a2], [b1, b2]] = Openskill.rate_with_ids([[{"a1", a1}, {"a2", a2}], [{"b1", b1}, {"b2", b2}]])
[
  [
    {"a1", {28.669648436582808, 8.071520788025197}},
    {"a2", {33.83086971107981, 5.062772998705765}}
  ],
  [
    {"b1", {43.071274808241974, 2.4166900452721256}},
    {"b2", {23.149503312339064, 6.1378606973362135}}
  ]
]

This function also has the option `:as_map` which can be used to produce a flat map of the results.
> [[a1, a2], [b1, b2]] = Openskill.rate_with_ids([[{"a1", a1}, {"a2", a2}], [{"b1", b1}, {"b2", b2}]], as_map: true)
%{
  "a1" => {28.669648436582808, 8.071520788025197},
  "a2" => {33.83086971107981, 5.062772998705765},
  "b1" => {43.071274808241974, 2.4166900452721256},
  "b2" => {23.149503312339064, 6.1378606973362135}
}
```

### Showing ratings
When displaying a rating, or sorting a list of ratings, you can use `ordinal`

```elixir
> Openskill.ordinal({43.071274808241974, 2.4166900452721256})
35.821204672425594
```

By default, this returns `mu - 3*sigma`, showing a rating for which there's a 99.5% likelihood the player's true rating is higher, so with early games, a player's ordinal rating will usually go up and could go up even if that player loses.

## TODO

- Support shuffled rankings, e.g. `Openskill.rank([[p1],[p2],[p3],[p4]], ranks: [1, 4, 2, 3])`.
- Support tied rankings, e.g. `Openskill.rank([[p1],[p2],[p3],[p4]], ranks: [1, 2, 2, 4])`
- Configurable alternate `gamma` to avoid ill-conditioning problems from large numbers of teams, as discussed in the paper.
