module BRAIN
  @@BRAIN = {}
  def self.[] k
    c = Classifier::LSI.new
    @@BRAIN.each_pair { |k,v| puts %[BRAIN #{k} #{v}]; c.add_item(k, v) }
    return c.classify(k)
  end
  def self.[]= k,v
    @@BRAIN[k] = v
  end
  def self.to_h
    @@BRAIN
  end
end

BRAIN["What time is it?"] = :time
BRAIN["We are at the park."] = :fact
BRAIN["What is the meaning of life?"] = :fact
BRAIN["Where is the train station?"] = :info

