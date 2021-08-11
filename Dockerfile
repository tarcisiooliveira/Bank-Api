FROM elixir:latest


RUN DEBIAN_FRONTEND=noninteractive apt-get update \
		&& apt-get install -y locales inotify-tools postgresql-client \
    && rm -rf /var/cache/apt \
    && mix local.hex --force \
    && mix local.rebar --force \
    && locale-gen
