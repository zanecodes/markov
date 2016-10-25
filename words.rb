#!/usr/bin/env ruby

require 'sinatra'
require './markov_model'

def generate_most_likely(model, chain=[])
  model.generate(chain) do |distribution|
    (distribution.probabilities.sort_by { |_, chance| chance }.last || []).first
  end
end

dictionaries = %w[
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

factors = (1..5)

MODELS = dictionaries.map do |name|
    [name, factors.map { |n| [n, "models/#{n}/#{name}.bin"] }.to_h ]
  end.to_h
MODELS.default = {}

def get_model(dictionary, factor)
  model = MODELS[dictionary][factor]

  if model.nil?
    get_model('english_35', 3)
  elsif model.is_a?(String)
    puts "Loading #{model}..."
    MODELS[dictionary][factor] = Marshal::load(File.new(model, mode: 'rb'))
  else
    model
  end
end

get '/' do
  dictionary = params['dictionary']
  factor = params['factor'].to_i

  model = get_model(dictionary, factor)
  model.generate.join.strip
end
