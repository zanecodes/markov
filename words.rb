#!/usr/bin/env ruby

require 'sinatra'
require './markov_model'

def generate_most_likely(model, chain=[])
  model.generate(chain) do |distribution|
    (distribution.probabilities.sort_by { |_, chance| chance }.last || []).first
  end
end

DICTIONARIES = {
  'english_10'  => 'en-US',
  'english_20'  => 'en-US',
  'english_35'  => 'en-US',
  'english_40'  => 'en-US',
  'english_50'  => 'en-US',
  'english_55'  => 'en-US',
  'english_60'  => 'en-US',
  'english_70'  => 'en-US',
  'english_80'  => 'en-US',
  'english_95'  => 'en-US',
  'german'      => 'de-DE',
  'japanese'    => 'ja-JP'
}

FACTORS = (1..3)

MODELS = DICTIONARIES.keys.map do |name|
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
  @language = DICTIONARIES[@dictionary]

  erb :index 
end

__END__

@@ index
<html>
<head>
<title>Markov Word Generator</title>
</head>
<body>
  <script>
    window.speechSynthesis.getVoices();
    function play() {
      var word = new SpeechSynthesisUtterance('<%= @word %>');
      word.voice = window.speechSynthesis.getVoices().filter(function(voice) { return voice.lang == '<%= @language %>'; })[0];
      window.speechSynthesis.speak(word);
    }
  </script>
  <h1 onclick="play()"><%= @word %></h1>
  <form method="get">
    <select name="dictionary">
      <% DICTIONARIES.keys.each do |name| %>
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
