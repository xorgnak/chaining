module BRAIN
  @@DB = PStore.new("db/brain.pstore")
  def self.[]= k, v
    @@DB.transaction { |db| db[k] = v }
  end
  def self.keys
    @@DB.transaction { |db| db.keys }
  end
  def self.brain &b
    c = Classifier::LSI.new
    @db.transaction { |db| db.keys.each { |e| c.add_item e, db[e] } }
    return b.call(c)
  end
end

BRAIN["What time is it?"] = :question
BRAIN["We are at the park."] = :statement

BRAIN["What is the meaning of life?"] = :philosophy
BRAIN["What time is it?"] = :information

#BRAIN.match("What is the meaning of life?")
