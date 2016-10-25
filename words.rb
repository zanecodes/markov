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

FACTORS = (1..3)

MODELS = DICTIONARIES.map do |name|
  [ name,
    FACTORS.map do |n|
      path = "models/#{n}/#{name}.bin"
      puts "Loading #{path}..."
      [n, Marshal::load(File.new(path, mode: 'rb'))]
    end.to_h ]
end.to_h

get '/' do
  @dictionary = params['dictionary'] || 'english_35'
  @factor = (params['factor'] || 3).to_i

  model = MODELS[@dictionary][@factor]
  @word = model.generate.join.strip

  erb :index 
end

__END__

@@ index
<html>
<head>
<title>Markov Word Generator</title>
</head>
<body>
  <h1><%= @word %></h1>
  <form method="get">
    <select name="dictionary">
      <% DICTIONARIES.each do |name| %>
        <option<%= ' selected' if name == @dictionary %>>
          <%= name %>
        </option>
      <% end %>
    </select>
    <select name="factor">
      <% FACTORS.each do |n| %>
        <option<%= ' selected' if n == @factor %>>
          <%= n %>
        </option>
      <% end %>
    </select>
    <input type="submit" value="Generate" />
  </form>
</body>
</html>
