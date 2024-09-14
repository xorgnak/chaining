module HERE
  @@H = Hash.new { |h,k| h[k] = H.new(k) }
  class H
    def initialize k
      @db = PStore.new("db/here-#{k}.pstore")
    end
    def [] k
      @db.transaction { |db| db[k] }
    end
    def []= k,v
      @db.transaction { |db| db[k] = v }
    end
    def keys
      @db.transaction { |db| db.keys }
    end
  end
  def self.[] k
    @@H[k]
  end
end
