#!/usr/bin/env ruby

require 'sinatra'
require './markov_model'

def generate_most_likely(model, chain=[])
  model.generate(chain) do |distribution|
    (distribution.probabilities.sort_by { |_, chance| chance }.last || []).first
  end
end

DICTIONARIES = %w[
  english_10
  english_20
  english_35
  english_40
  english_50
  english_55
  english_60
  english_70
  english_80
  english_95
  german
]

FACTORS = (1..5)

MODELS = DICTIONARIES.map do |name|
  [ name,
    FACTORS.map do |n|
      path = "models/#{n}/#{name}.bin"
      puts "Loading #{path}..."
      [n, Marshal::load(File.new(path, mode: 'rb'))]
    end.to_h ]
end.to_h

get '/' do
  dictionary = params['dictionary'] || 'english_35'
  factor = (params['factor'] || 3).to_i

  model = MODELS[dictionary][factor]
  model.generate.join.strip
end
