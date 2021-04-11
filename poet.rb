# Simple poem generator implemented using Markov chain
class Poet
  require 'set'

  def initialize(training_set)
    @word_chain =
      training_set
        .split
        .each_cons(3)
        .map { |a, b, c| { [a, b] => Set[c] } }
        .reduce { |acc, cur| acc.merge(cur) { |_, a, b| a + b } }
  end

  def walk_chain(prefix)
    result   = [*prefix]
    suffixes = @word_chain[prefix]

    while suffixes && result.size < 100
      suffix   = suffixes.to_a.sample
      prefix   = [prefix.last, suffix]
      suffixes = @word_chain[prefix]
      result << suffix
    end

    result
  end

  def create_poetry
    start = @word_chain.keys.sample
    text = walk_chain(start).join(' ')
    # ensure text starts with a capital letter and ends with . or !
    m = /(?=[A-Z]).*[.!][")]?/.match(text)
    m[0] unless m.nil?
  end
end

files        = Dir['./*.txt']
training_set = files.map { |f| File.open(f).read }.join(' ')
poet         = Poet.new(training_set)

5.times do
  poetry = poet.create_poetry
  File.write('output.txt', poetry + "\n\n", mode: 'a')
end
