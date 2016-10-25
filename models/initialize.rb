#!/usr/bin/env ruby

require 'tqdm'
require '../markov_model'

n = (ARGV.shift || 1).to_i
words = ARGF.each_line.lazy.map(&:downcase).map(&:chars).tqdm
model = MarkovModel.new(words, n)
Marshal::dump(model, STDOUT.binmode)
