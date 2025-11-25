#!/usr/bin/env elixir

Mix.install([{:eaoc, path: "."}])

args = System.argv()
CommandLine.handle(args)
