module Chaining
  
  def self.input h={}
    a = []
    hx = h.clone
    hx.delete(:response)
    hx.each_pair { |k,v| a << %[#{k}="#{v}"] }
    return %[<p class='input'><input #{a.join(" ")}></p>]
  end

  def self.textarea h={}
    a = []
    hx = h.clone
    hx.delete(:response)
    hx.each_pair { |k,v| a << %[#{k}="#{v}"] }
    return %[<p class='textarea'><textarea #{a.join(" ")}></textarea></p>]
  end
 
  @@INTAKE = Hash.new { |h,k| h[k] = InTake.new(k) }
  class InTake
    def initialize k
      @db = PStore.new("db/intake-#{k}.pstore")
    end
    def []= k, h={}
      @db.transaction { |db| db[k] = h }
    end
    def [] k
      @db.transaction { |db| db[k] }
    end
    def delete k
      @db.transaction { |db| db.delete(k) }
    end
    def form
      a = []
      @db.transaction do |db|
        db.keys.each do |e|
          h = db[e]
          h[:name] = e
          puts %[#{h}]
          if h[:response] == 'long'
            a << Chaining.textarea(h)
          else
            a << Chaining.input(h)
          end
        end
      end
      return a.join("")
    end
    def to_h
      h = {}
      @db.transaction { |db| db.keys.each { |e| h[e] = db[e] } }
      return h
    end
  end
  def self.intake
    @@INTAKE
  end
end
