module Chaining
  def self.fortune *c
    `fortune -s #{c[0] || 'fortunes'}`.strip
  end
end
