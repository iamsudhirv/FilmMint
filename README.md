# Film Mint

Greenlighting decision-support for film producers. Build a **package** (cast + key crew) for a project,
see each person's **value by territory**, whether they are **worth their fee**, a **risk score**,
and how an introduction path through **your network** gets you to them.

Rails 8 API (this folder) + Vue 3 / Vite frontend (`frontend/`) + PostgreSQL.

## Run locally

Needs Ruby 3.4, Node 20+, a running PostgreSQL.

```
bundle install
bin/rails db:setup            # creates DB, loads schema, seeds data sources + DEMO data
(cd frontend && npm install)
script/dev                    # API http://localhost:3100  +  UI http://localhost:5173
```

Tests: `bin/rails test`. API URL for the UI is `frontend/.env.development` (`VITE_API_URL`).

## What is in the box

| Screen | What it does |
|---|---|
| Projects | Create projects (genre, budget, story's political leaning) |
| Project → package | Add/remove people, valuation, risk flags, territory sales bars, **what-if** swap with before/after |
| People → card | Where a person's films sold (by territory), fee, persona and politics signals, credits |
| My Network | Shortest introduction path to anyone, drawn as a thread |
| Data Sources | The scraping/API source list with terms-of-service status |

## Important: demo data

Every person, film and number seeded by `db/seeds/demo.rb` is **fictional**. Replace it with imported
real data before relying on any output. The valuation (`app/services/package_valuation.rb`) is a transparent
heuristic with tunable constants (presale ratio, billing weights, risk points), not a calibrated model.

## Next steps

- Importers (TMDB, OMDb, Wikidata, IMDb datasets) as Solid Queue jobs, storing `source` + `fetched_at` per record.
- Auth and per-user networks (today "you" is one seeded person).
- Calibrate the valuation with real sales-agent feedback; persist scenarios.
- Draggable thread UI; move path search to SQL/graph store when the network grows.
- Persona/politics inputs: keep them human-entered and factual; do not auto-label people.
