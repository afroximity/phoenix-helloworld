# ----------------------
# Build Stage
# ----------------------
FROM elixir:1.15-alpine AS build

RUN apk add --no-cache build-base npm git python3

ENV MIX_ENV=prod

RUN mix local.hex --force && \
    mix local.rebar --force

WORKDIR /app

# Copy mix setup
COPY mix.exs mix.lock ./
COPY config config
RUN mix deps.get --only prod
RUN mix deps.compile

# Copy ALL project files BEFORE asset build
COPY lib lib
COPY priv priv
COPY rel rel
COPY assets assets

# Install Node deps (Tailwind etc.)
RUN npm --prefix ./assets ci --progress=false --no-audit --loglevel=error

# Build assets AFTER everything is present
RUN mix assets.deploy

# Compile final app
RUN mix compile

# Build release
RUN mix release

# ----------------------
# Deploy Stage
# ----------------------
FROM alpine:3.18 AS app

# Install runtime dependencies
RUN apk add --no-cache openssl ncurses-libs libstdc++ bash

WORKDIR /app
RUN chown nobody:nobody /app
USER nobody:nobody

# Copy release from build stage
COPY --from=build --chown=nobody:nobody /app/_build/prod/rel/phoenix_liveview_demo ./

ENV HOME=/app

# Required by Render
EXPOSE $PORT

# Launch app
CMD ["bin/phoenix_liveview_demo", "start"]
