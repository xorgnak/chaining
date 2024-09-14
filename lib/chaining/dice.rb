module DICE
  def self.[] k
    a, r, kk = [], 0, k.split("d")
    kk[0].to_i.times { |t| x = rand(1..kk[1].to_i); r += x; a << x; }
    return { total: r, results: a }
  end
end
