#!/usr/bin/env zsh
mix run -e 'System.argv() |> CommandLine.handle' -- $@
