####!/usr/bin/env just --working-directory . --justfile
# vim: set ft=make :

watch-run:
	cargo watch -x run

build:
	yarn routify -b
	yarn snowpack build --polyfill-node

resetdb-xapp:
	psql -c 'CREATE DATABASE xapp; GRANT ALL PRIVILEGES ON DATABASE xapp TO xapp;'
	diesel migration run
	diesel migration list
	diesel print-schema > diesel-print-schema.rs
	# psql -f scheduler/crates/infra/migrations/dbinit.sql  xapp-db xapp

migrations-down:
	#!/bin/bash
	for df in `fd down.sql migrations `; do
		psql xapp -f ${df}
	done
	for tab in __diesel_schema_migrations _sqlx_migrations ; do
		psql xapp -c "drop table if exists ${tab}"
	done

print-schema:
	diesel print-schema > diesel-print-schema.rs

_:
	# select * from users; select * from posts; select * from sessions;

# alias xsql='/bin/cat | psql'

create-feapp dirname:
	# https://github.com/snowpackjs/snowpack/blob/main/create-snowpack-app/cli/README.md
	npx create-snowpack-app {{dirname}} --template @snowpack/app-template-svelte --use-yarn

create-feapp-ts dirname:
	# https://github.com/snowpackjs/snowpack/blob/main/create-snowpack-app/cli/README.md
	npx create-snowpack-app {{dirname}} --template @snowpack/app-template-svelte-typescript --use-yarn

create-feapp-wasm dirname:
	# https://github.com/snowpackjs/snowpack/blob/main/create-snowpack-app/cli/README.md
	npx create-snowpack-app {{dirname}} --template snowpack-template-ts-rust-wasm --use-yarn
