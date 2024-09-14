module REM
  @@R = Hash.new { |h,k| h[k] = Rem.new(k) }
  class Rem
    def initialize k
      @key = k
      @db = PStore.new("db/rem-#{k}.pstore")
    end
    def keys
      @db.transaction { |db| db.keys }
    end
    
    def []= k, v
      Nickel.parse("#{k} #{v}").occurrences.each_with_index { |e, idx|
        h = {} 
        if e.start_time
          h[:hour] = e.start_time.to_time.strftime("%k")
          h[:minute] = e.start_time.to_time.strftime("%M")
          h[:date] = e.start_date.to_date.strftime("%Y/%m/%-d")
        else
          h[:hour] = "00"
          h[:minute] = "00"
          h[:date] = e.start_date.to_date.strftime("%Y/%m/%-d")
        end
        h[:message] = %[#{h[:date]} #{h[:hour]}:#{h[:minute]} #{k} ##{idx}]
        puts %[REM=> #{h}]
        @db.transaction { |db| db[h[:message]] = h  }
      }
    end
    
    def write!
      x, h = [], {}
      @db.transaction { |db| db.keys.each { |e| h[e] = db[e] } }
      h.each_pair do |kk, vv|
        x << %[REM #{vv[:date]} AT #{vv[:hour]}:#{vv[:minute]} MSG #{kk}\n]
      end
      File.open("rems/#{@key}.rem",'w') { |f| f.write(x.join("\n")); }
    end
    def text
      File.read("rems/#{@key}.rem")
    end
    def [] q
      write!
      qq, qqq = [], []
      @q = Regexp.new(q)
      `remind -t4 rems/#{@key}.rem`.strip.split("\n").compact.each { |e| if @q.match(e); qq << e; end; }
      qq.map { |e| if "#{e}".length > 0; e; end }.compact.each { |e|
        if m = /^(?<d>\d+\/\d+\/\d+)(?<t> \d+:\d\d)? (?<e>.*) #(?<x>.+)$/.match(e);
          qqq << { date: m[:d].strip, time: m[:t].strip, occourance: m[:x].strip, message: m[:e].strip }
        end
      }
      return qqq
    end
  end
  def self.keys
    @@R.keys
  end
  def self.[] k
    @@R[k]
  end
end
  
