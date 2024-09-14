module DB
  @@DB = Hash.new { |h,k| h[k] = Db.new(k) }
  class Db
    def initialize k
      @type = k
      @keys = []
    end
    def keys *k
      if k[0]
        @keys = [k].flatten.uniq
      else
        @keys
      end
    end
    def [] k, &b
      PStore.new("db/#{@type}-#{k}.pstore").transaction { |db| b.call(db) }
    end
  end
  def self.db
    @@DB
  end

  @@TBL = Hash.new { |h,k| h[k] = Tbl.new(k) }
  class Tbl
    def initialize k
      @key = k
      @tbl = CSV.table("csvs/#{k}.csv")
    end
    def []= k,v
      DB.db[:table][@key] { |db| db[k] = v }
    end
    def headers
      @tbl.headers
    end
    def csv
      @tbl
    end
    def [] k
      if k.class == Symbol
        DB.db[:table][@key] { |db| db[k] }
      elsif k.class == Integer
        @tbl[k].to_h
      end
    end
    def each_pair &b
      @tbl.each_with_index { |e,i| b.call(i,e) }
    end
    def filter(h={})
      hh = Hash.new { |h,k| h[k] = [] }
      h.each_pair { |kk,vv|
        each_pair { |k,v| if Regexp.new(vv).match(@tbl[k].to_h[kk]); hh[vv] << k; end }
      }
      return hh
    end
  end
  def self.csv
    @@TBL
  end
  Dir['csvs/*.csv'].each { |e| ee = e.gsub("csvs/", "").gsub(".csv", ""); @@TBL[ee] }
  
  @@TXT = Hash.new { |h,k| h[k] = Txt.new(k) }
  class Txt
    def initialize k
      @txt = []
      File.read("txts/#{k}.txt").gsub(/\n\n+/, "\n\n").split("\n\n").each_with_index do |e, i|
        #e.gsub("\n"," ").split(". ").each_with_index { |ee, ii| @txt[i][ii] = ee }
        @txt[i] = e.gsub("\n", "")
      end
    end
    def [] k
      @txt[k]
    end
    def each_pair &b
      @txt.each_with_index { |e,i| b.call(i,e) }
    end    
    def filter(*q)
      h = Hash.new { |h,k| h[k] = [] }
      each_pair do |i,ee|
        [q].flatten.each { |e| if Regexp.new("[[:space:]]#{e}[[:space:]]").match(ee); h[e] << i; end }
      end
      return h
    end
    def to_a
      @txt
    end
  end
  def self.txt
    @@TXT
  end
  Dir['txts/*.txt'].each { |e| ee = e.gsub("txts/", "").gsub(".txt", ""); @@TXT[ee] }

  
  MD = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
  @@MD = Hash.new { |h,k| h[k] = Md.new(k) }
  class Md
    def initialize k
      @k = k
    end
    def md
      ERB.new(File.read("md/#{@k}.md.erb")).result(binding)
    end
    def html
      MD.render(md)
    end
  end
  def self.md
    @@MD
  end

  @@PRO = Hash.new { |h,k| h[k] = Pro.new(k) }

  class Pro
    attr_reader :txt, :csv
    def initialize k
      @key = k
      @txt = DB.txt[k]
      @csv = DB.csv[k]
    end
    def []= k,v
      DB.db[:project][@key].transaction { |db| db[k] = v }
    end
    def [] k
      DB.db[:project][@key].transaction { |db| db[k] }
    end
  end
  
  def self.projects
    @@PRO.keys
  end
  
  def self.[] k
    @@PRO[k]
  end
  
  def self.csvs h={}
    hh = {}
    @@TBL.each_pair { |k,v| hh[k] = v.filter(h) }
    return hh
  end

  def self.txts *q
    hh = {}
    @@TXT.each_pair { |k,v| hh[k] = v.filter(q) }
    return hh
  end

  def self.find q
    { txt: DB.txts(q), csv: DB.csvs(description: q) }
  end
  
  def self.to_h
    {
      txt: @@TXT.keys,
      csv: @@TBL.keys,
      md: @@MD.keys,
      db: @@DB.keys
    }
  end
end
