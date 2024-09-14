module WIKI
  @@DB = PStore.new("db/wiki.pstore")
  def self.[]= k,v
    @@DB.transaction { |db| db[k] = v }
  end
  def self.[] k
    h = {}
    @@DB.transaction { |db| db.keys.each { |e| if k == e || Regexp.new(k.downcase).match(db[e].downcase); h[e.downcase] = db[e].downcase; end } }
    return h
  end
  def self.keys
    @@DB.transaction { |db| db.keys }
  end
end

WIKI['denver'] = "capitol of Colorado"
WIKI['cats'] = "felines"
WIKI['cat'] = "feline"
WIKI['work'] = "hours of production"
