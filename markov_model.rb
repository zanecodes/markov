require 'zlib'
require 'categorical_distribution'
require 'multiset'

class MarkovModel
  def initialize(chains, n=1)
    raise ArgumentError, 'markov factor must be greater than zero' if n < 1

    @table = Hash.new(CategoricalDistribution.new)
    @n = n

    map = Multimap.new

    chains.each do |chain|
      chain.each_with_index do |state, i|
        map[Zlib.crc32(chain.first(i).last(n).to_s)] << state
      end
    end

    map.each_pair_list do |subchain_hash, distribution|
      @table[subchain_hash] = CategoricalDistribution.new(distribution.to_hash)
    end

    @table.freeze
  end

  def [](*chain)
    @table[Zlib.crc32(chain.flatten.last(@n).to_s)]
  end

  def generate(chain=[], random=Random)
    loop do
      state = block_given? ? yield(self[chain]) : self[chain].rand(random: random)
      return chain if state.nil?
      chain << state
    end
  end
end
