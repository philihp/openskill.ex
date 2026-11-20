# openskill.ex 2.0 — project plan

Status: proposal. No code is changed yet.

## 1. Goal

Release `openskill` 2.0.0 on Hex. For each model and each option, version 2.0
gives the same numbers as [openskill.js](https://github.com/philihp/openskill.js)
5.1, bit for bit. openskill.js is the reference, because it is parity-tested
against openskill.py 6.2. Where openskill.js must change first, section 4 lists
the change.

The library also gets the features that openskill.js has and this library does
not have, a current toolchain, and documentation on HexDocs.

## 2. Where the library is now

These are measurements from 2026-11-17, on Elixir 1.20.5 and Erlang/OTP 28.

### 2.1 Release state

- Hex has version 1.0.1, published 2020-04-22.
- `master` is 23 commits ahead of `v1.0.1`. `rate_with_ids/2` (2023),
  `predict_win/1` and the `tau` option (2026-05) are on `master` only.
- Hex shows 2,171 downloads in total, and 1,116 of them are recent.
- The Beyond All Reason team uses a fork (`Teifion/openskill.ex`), because this
  library had no `tau` (issue #23).
- The 73 tests pass.

### 2.2 Numbers compared with openskill.js

The comparison used 180 random games (2 to 5 teams, 1 to 5 players in a team),
each of the 5 models, and `tau` of 0 and 25/300. That gives 1,800 output numbers
for each model and each `tau`. The ranks were the default ranks, because
`master` supports no other ranks.

| Model | Bit-exact outputs | Largest difference | Cause |
|---|---|---|---|
| Plackett-Luce | 98.7% | 1 ulp | `exp` |
| Bradley-Terry full | 99.8% | 1 ulp | `exp` |
| Bradley-Terry part | 99.8% | 1 ulp | `exp` |
| Thurstone-Mosteller full | 0.2% | 0.42 in `mu` | normal CDF |
| Thurstone-Mosteller part | 0% | 15.9 in `mu` | normal CDF, and a different formula |
| `predict_win` | 0% | 7e-8 | normal CDF |

The causes:

1. **`exp`.** `:math.exp/1` calls the platform libm. Node.js (V8) uses its own
   fdlibm code. The two agree on 90.3% of 200,000 random inputs. On the other
   inputs they differ by 1 ulp.
2. **Normal CDF.** The `statistics` package calculates the CDF with an error up
   to 7e-8. In the tails of the distribution, that error is larger than the
   value. This makes the Thurstone-Mosteller results wrong, not only different.
3. **Thurstone-Mosteller part.** openskill.js and openskill.py use
   `c = 2 * sqrt(...)`. This library uses `c = sqrt(...)`.
4. **Thresholds.** `v/2` and `w/2` change to their fallback below `2.2e-162`.
   openskill.js uses `2.2e-16`.

### 2.3 Options and functions

| Item | openskill.js 5.1 | `master` |
|---|---|---|
| `rank` | yes, with ties and any order | `ranks` is accepted and ignored |
| `score` | yes | no |
| `weight`, `weightBounds` | yes | `weights` is accepted and ignored |
| `tau` | default 25/300 | default 1/3 |
| `limitSigma` | yes | yes, as `prevent_sigma_increase` |
| `margin` | yes | no |
| `balance` | yes | no |
| `windowSize` | yes | no |
| `gamma` function | yes | no |
| `mu`, `sigma`, `beta`, `z`, `kappa`, `epsilon` for each call | yes | no, they are compile-time constants |
| `ordinal` with `alpha`, `target` | yes | no |
| `predictWin` | yes | yes, without options |
| `predictDraw`, `predictRank` | yes | no |
| Ties in 3 or more teams | yes | no |

Other items:

- `Openskill.rating/0` returns `{25, 8.333333333333334}`. The `mu` is an
  integer.
- An option with a wrong name is ignored without an error.
- The Plackett-Luce model reads `sum_q` and `a` with the rank value as the key,
  but it writes them with the team position as the key. PR #37 corrects this.
- The models have no typespecs and no documentation. There is no changelog.
- CI runs one Elixir version, only on `push`. There is no format check and no
  `mix.lock`.

## 3. Design decisions

### 3.1 The reference is a set of fixtures from openskill.js

A Node.js script runs openskill.js on a fixed list of cases and writes the
inputs and outputs to JSON files. The Elixir tests read these files and compare
with `==`. No tolerance is permitted.

- The script uses a pinned version of openskill.js. Until 5.1.1 is on npm, it
  pins the git commit. After that, it pins the npm version.
- A JSON number keeps the full value of a float, because JavaScript writes the
  shortest text that reads back to the same float.
- The cases come from two sources: the constants in the openskill.js parity
  tests (these come from openskill.py), and random games from a seeded
  generator.
- A case for a feature that is not yet built has a `pending` tag. A list of
  pending tags is in the test helper. Each pull request removes tags from the
  list. The list is empty at the release.
- A CI job runs the script again and fails if the files change. This keeps the
  fixtures and the script in agreement.

pg_openskill uses the same method with `scripts/generate-fixtures.mjs`.

### 3.2 The math functions are pure Elixir

The library gets a module `Openskill.Math` with ports of the functions that
openskill.js uses:

- `exp/1`: fdlibm `e_exp.c`, which V8 uses.
- `erfc/1`: the FreeBSD `s_erf.c` code, which `@stdlib/math-base-special-erfc`
  uses.
- `normal_quantile/1`: the code in `@stdlib/stats-base-dists-normal-quantile`,
  which calls `@stdlib/math-base-special-erfinv`. Only `predict_draw` uses it.

The normal CDF is `0.5 * erfc(-x / sqrt(2))`. This is the formula of Python
3.14 and of `@stdlib/stats-base-dists-normal-cdf`. Python 3.13 and earlier use
`0.5 * (1 + erf(x / sqrt(2)))`, and openskill.js 5.1 uses that earlier formula.
The library does not port the earlier formula, for two reasons:

- The earlier formula loses accuracy in the lower tail. For `x` less than -3,
  its relative error is up to 100%. The relative error of the `erfc` formula
  is 1e-14 in the same range.
- openskill.py calls `statistics.NormalDist` of the Python that runs it. On
  Python 3.14, openskill.py 6.2.0 gives different Thurstone-Mosteller numbers
  than on Python 3.13. In a test of 360 random games, 39% of the outputs of
  the full model were different, by up to 0.013. The Plackett-Luce and
  Bradley-Terry outputs were equal.

openskill.js must change to the `erfc` formula before the fixtures for the
Thurstone-Mosteller models and the predictions are made. Section 4 lists this
change.

`sqrt`, `+`, `-`, `*` and `/` are correctly rounded by IEEE 754, so they need
no port. The operations must be in the same sequence as in openskill.js,
because float addition is not associative. A square is `x * x`. The `**`
operator calls the platform `pow`, so the code does not use it.

A test of an `exp/1` port gave 200,000 of 200,000 results equal to V8. The port
takes 229 ns for each call and `:math.exp/1` takes 26 ns. A rating calculation
calls `exp` a small number of times, so the cost is not important.

The `math` and `statistics` dependencies are removed. The library then has no
runtime dependencies.

pg_openskill made the same decision for `exp`. Its README also records a risk:
some arm64 builds of Node.js use fused multiply-add, and they differ from the
V8 source by 1 ulp on approximately 0.1% of inputs. The fixtures are always
made on x64. CI runs the Elixir tests on x64 and on arm64.

### 3.3 Public API

Ratings stay as `{mu, sigma}` tuples. Options stay as a keyword list. This
keeps the existing calls and the fork users' code valid.

```elixir
Openskill.rating(mu \\ nil, sigma \\ nil)   # {25.0, 8.333333333333334}
Openskill.ordinal(rating, opts \\ [])
Openskill.rate(teams, opts \\ [])
Openskill.rate_with_ids(teams, opts \\ [])
Openskill.predict_win(teams, opts \\ [])    # [float]
Openskill.predict_draw(teams, opts \\ [])   # float
Openskill.predict_rank(teams, opts \\ [])   # [{rank, probability}]
```

Option names are the openskill.js names in snake case:

`model`, `rank`, `score`, `weight`, `weight_bounds`, `tau`, `limit_sigma`,
`margin`, `balance`, `window_size`, `gamma`, `mu`, `sigma`, `beta`, `z`,
`kappa`, `epsilon`, `alpha`, `target`. `rate_with_ids/2` keeps `as_map`.

Rules:

- An option with an unknown name raises `ArgumentError`. The message gives the
  new name for `ranks`, `weights` and `prevent_sigma_increase`.
- One function builds the constants from the options. Each model reads the
  constants from that result. No model uses a module attribute for a constant.
- `Openskill.Model` is a behaviour with one callback, `rate/2`. The 5 models
  implement it. A user can supply a model.
- All public functions have a `@spec` and a `@doc` with a doctest.

### 3.4 Version and compatibility

The release is 2.0.0, because default results change:

- `tau` is applied by default, with the value 25/300.
- The Thurstone-Mosteller models give different numbers.
- Unknown options raise an error.
- `rating/0` returns floats.

`master` is not released as 1.x without a change, because its default `tau` of
1/3 changes the results of each call. The models did not change after
`v1.0.1`, so `master` with a `tau` of 0 gives the 1.0.1 results.

### 3.5 Code style

- Functions are pure. Data flows through pipelines.
- Shared steps are shared functions. For example, all models use one
  `update_player` function, as in openskill.js.
- `mix format` sets the layout.

## 4. Work packages

Each item is one pull request. The letter shows the lane. Lane A and lane B can
run at the same time. Inside a lane, the items run in sequence, because they
change the same files.

### Changes in openskill.js that come first

These changes are in the openskill.js repository. They are not in the count of
pull requests for this repository.

| ID | Change in openskill.js | Necessary for |
|---|---|---|
| J1 | The normal CDF uses the `erfc` formula of Python 3.14. | A2, B4, C6 |
| J2 | `predictWin` and `predictDraw` use `n * beta²` and `players * beta²` in the denominator. openskill.py 6.2.0 uses `2 * beta²` in the two functions. The results differ by up to 0.03 and 0.07. The owner decides which formula is the reference. | C6 |

### Phase 0 — Base

| ID | Pull request | Depends on |
|---|---|---|
| 0.1 | **Release 1.1.0.** `master` with the default `tau` set to 0, so results are equal to 1.0.1. Adds a changelog. Gives Hex users `rate_with_ids`, `predict_win` and `tau` now. Closes #23 and #24. | — |
| 0.2 | **CI and toolchain.** Run on pull requests. Test the oldest and the newest supported Elixir and OTP, on x64 and arm64. Add `mix format --check-formatted` and `--warnings-as-errors`. Commit `mix.lock`. Merge Renovate PRs #38, #39 and #41. | — |
| 0.3 | **Fixture system.** The generator script, the first fixture files, the test that reads them, the pending list, and the CI job that checks the files. | 0.2 |

### Phase 1 — Math (lane A)

| ID | Pull request | Depends on |
|---|---|---|
| A1 | `Openskill.Math.exp/1`, with fixtures of raw `exp` values. | 0.3 |
| A2 | `Openskill.Math.erfc/1`, the normal PDF and CDF, and `v`, `w`, `vt`, `wt` with the openskill.js thresholds. Remove `math` and `statistics`. | A1, J1 |
| A3 | `Openskill.Math.normal_quantile/1`. | A2 |

### Phase 2 — Engine (lane B)

| ID | Pull request | Depends on |
|---|---|---|
| B1 | **Options and constants.** Validation, the constants builder, the `Openskill.Model` behaviour, defaults equal to openskill.js. `rating/0` returns floats. | 0.3 |
| B2 | **Ranks, scores and ties in `rate/2`.** Sort the teams by rank, call the model, put the teams back. Plackett-Luce reads by team position. This replaces PR #37. | B1 |
| B3 | **Bradley-Terry full and part.** Ties, comparison by team position, shared `update_player`. | B2, A1 |
| B4 | **Thurstone-Mosteller full and part.** Ties with `vt` and `wt`, the `2 * sqrt` formula in the part model. | B3, A2 |

After B4, all 5 models agree with openskill.js for `rank`, `score`, `tau` and
`limit_sigma`.

### Phase 3 — Features

| ID | Pull request | Depends on |
|---|---|---|
| C1 | `weight` and `weight_bounds` (partial play). | B4 |
| C2 | `margin` with `score`. | B4 |
| C3 | `balance`. | B4 |
| C4 | `window_size` for the part models. | B4 |
| C5 | `gamma` function. | B4 |
| C6 | `predict_win/2` with options, `predict_draw/2`, `predict_rank/2`, `ordinal/2` with `alpha` and `target`. | B1, A3, J2 |

C1 to C5 change the same functions. Run a maximum of 2 at the same time.

### Phase 4 — Release

| ID | Pull request | Depends on |
|---|---|---|
| D1 | **Documentation.** ExDoc configuration, module documents, a new README, `CHANGELOG.md`, a guide to move from 1.x to 2.0. | C1–C6 |
| D2 | **Checks.** Dialyzer, and property tests: the output has the shape of the input, `predict_win` sums to 1, `limit_sigma` never increases `sigma`. | C1–C6 |
| D3 | **Release workflow.** A GitHub release publishes to Hex and HexDocs. The owner adds the `HEX_API_KEY` secret. Publish `2.0.0-rc.1`. | D1, D2 |
| D4 | **Release 2.0.0.** Close #13 and #15. Tell the Beyond All Reason team in issue #23. | D3, owner approval |

The total is 20 pull requests in this repository.

## 5. Risks

| Risk | Control |
|---|---|
| A port of `erfc` or `normal_quantile` does not agree with openskill.js. | Fixtures of raw function values in A2 and A3 show the first bad input. The source is small and public. |
| The BEAM gives different float results on arm64. | CI runs on arm64 from 0.2. |
| openskill.js changes during the project. | The fixtures pin one version. A later version is a new, small pull request that changes the pin and the fixtures. |
| openskill.js 5.1.1 is not on npm. | The script pins the git commit. The release of 5.1.1 is a different task. |
| Fork users have different results after the upgrade. | The 1.x to 2.0 guide lists each change and the option that gives the old result. `2.0.0-rc.1` gives time for tests. |

## 6. Decisions for the owner

1. **Release 1.1.0 first (item 0.1)?** Recommended: yes. It costs one pull
   request, and Hex has had no release since 2020.
2. **Default `window_size`.** openskill.js 5.1 compares adjacent teams by
   default, and its changelog says that version 6 will use 4. Recommended:
   use 4 in 2.0.0, so that a later change of the default is not necessary.
   The fixtures always give `window_size`, so parity tests are not affected.
3. **Minimum Elixir version.** Recommended: the oldest version that still gets
   security patches when 2.0.0 is released.

## 7. Toolchain for a cloud session

The cloud container has no Elixir. These commands install it in approximately
one minute:

```bash
mkdir -p /opt/beam/otp /opt/beam/elixir && cd /opt/beam
curl -sSfL -o otp.tar.gz https://builds.hex.pm/builds/otp/amd64/ubuntu-24.04/OTP-28.5.0.8.tar.gz
tar xzf otp.tar.gz -C otp --strip-components=1 && (cd otp && ./Install -minimal "$PWD")
curl -sSfL -o elixir.zip https://builds.hex.pm/builds/elixir/v1.20.5-otp-28.zip
(cd elixir && unzip -q -o ../elixir.zip)
export PATH=/opt/beam/otp/bin:/opt/beam/elixir/bin:$PATH LC_ALL=C.UTF-8
```
