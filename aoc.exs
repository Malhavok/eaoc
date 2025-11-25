#!/usr/bin/env elixir

Mix.install([{:eaoc, path: "."}])

[day, year] = System.argv()
Init.day(String.to_integer(day), String.to_integer(year))
