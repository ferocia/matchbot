#!/usr/bin/env bash

postgres.ensure_correct_version_running() {
  # we just stop the old version and then start a new one
  kill "$(pgrep -f '.asdf/installs/postgres')"

  pg_ctl start
}
