#!/usr/bin/env zsh
mix run -e 'apply(CommandLine, :handle, System.argv())' -- $@
