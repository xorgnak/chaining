module MAID
  class Maid
    def initialize k
      @k = k
      @db = MaidDB.new(k)
    end
    def to_s
      ERB.new(File.read("maid/#{@k}.erb")).result(binding)
    end
  end
  class MaidDB
    def initialize k
      @db = PStore.new("db/maid-#{k}.pstore")
    end
    def [] k
      @db.transaction { |db| db[k] }
    end
    def []= k,v
      @db.transaction { |db| db[k] = v }
    end
  end
  def self.[] k
    Maid.new(k)
  end
end
