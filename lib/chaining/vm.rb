module VM
  class Vm
    attr_accessor :output, :here
    def initialize k
      @here = k
      @vm = VmSh.new(k)
      @db = VmDb.new(:vm, k)
    end
    def [] k
      @db[k]
    end
    def []= k,v
      @db[k] = v
    end
    def << s
      @vm.instance_eval(s)
    end
    def to_s
      x = @vm.output
      @vm.output = ""
      return x
    end
    def vm
      @vm
    end
    class VmSh
      attr_accessor :output
      def initialize k
        @key = k
        @csv = VmDb.new(:csv, k)
        @txt = VmDb.new(:txt, k)
        @img = VmDb.new(:img, k)
        @set = VmSet.new(:set, k)
        @rem = REM[k]
        @here = HERE[k]
        @output = %[]
      end
      
      def system(*a)
        %[No.]
      end 

      def unit
        UNIT
      end

      def dice
        DICE
      end
      
      def fortune *c
        Chaining.fortune c[0]
      end
      
      def document
        JOB[@key]
      end
      
      def title *n
        if n[0]
          JOB[@key][:name] = n[0]
        else
          JOB[@key][:name]
        end
      end
      
      def todo p, t, h={}
        JOB[@key].section[p][:name] = p
        JOB[@key].section[p].task[t][:name] = t
        h.each_pair { |k,v| JOB[@key].section[p].task[t][k.to_sym] = v }
      end
      
      def csv n, *s
        if s[0]
          a = []
          CSV.table("public/#{s[0]}").each_entry do |r|
            a << r.to_h
          end
          @csv[n] = a
        end
        if block_given?
          @csv[n].each_with_index { |e,i| b.call(i, e) }
        else
          @csv[n]
        end
      end

      def csvs h={}
        if h.keys.length == 0
          return @csv.keys
        else
          ah = {}
          @csv.keys.each  { |k| ah[k] = {}; csv(k) { |i,e| h.each_pair { |kk,vv| if Regexp.new(vv).match(e[kk]); ah[k][vv] ||= []; ah[k][vv] << i; end } } }
          return ah
        end
      end
      
      def txt n, *s
        if s[0]
          a = []
          File.read("public/#{s[0]}").gsub(/\r/,"").split("\n\n").compact.each_with_index { |e, i|
            aa = []
            e.gsub(/\n/, " ").gsub(/[[:space:]]+/," ").split(/[\.\?] /).compact.each_with_index { |ee, ii|
              eee = ee.gsub("*", "")
              if eee.split(" ").length > 0
                puts %[TXT #{i} #{ii}\t#{ee.split(" ").length}\t#{ee}]
                aa << eee.strip;
              end
            };
            if aa.compact.length > 0
              a << aa.compact
            end
          }         
          @txt[n] = a.compact
        else
          return @txt[n]
        end
      end
      
      def txts *r
        if !r[0]
          return @txt.keys
        else
          h = Hash.new { |h,k| h[k] = [] }
          [r].flatten.each_with_index do |rx, ri|
            rr = Regexp.new(rx)
            @txt.keys.each { |k| txt(k).each_with_index { |e,i| e.each_with_index { |ee,ii| if m = rr.match(ee); h[rx] << { txt: k, section: i, subsection: ii, regexp: rx, match: m, text: ee }; end } } }
          end
          return h
        end
      end
      
      def img n, *s
        if s[0]
          @img[n] = s[0]
        else
          @img[n]
        end
      end

      def rem n, *s
        if s[0]
          @rem[n] = s[0]
        else
          @rem[n]
        end
      end

      def here n, *s
        if s[0]
          @here[n] = s[0]
        else
          @here[n]
        end
      end
      
      def imgs
        @img.keys
      end
      
      def echo *s
        [s].flatten.map { |e| @output += %[#{e}\n] }
        @output += %[\n]
      end

      def compile h={}
        a = []
        if h.has_key?(h[:txt])
          echo txts(h[:txt])
        end
        if h.has_key?(h[:rem])
          echo rem(h[:rem])
        end
        if h.has_key?(h[:here])
          echo here(h[:here])
        end
        if h.has_key?(h[:wiki])
          echo wiki(h[:wiki])
        end
#        a << h.has_key?(e) ? csvs(e) : nil
        return a.flatten.compact
      end
    end
    class VmRem
      def initialize t, k
        @db = REM["#{t}-#{k}"]
      end
    end

    class VmHere
      def initialize t, k
        @db = HERE["#{t}-#{k}"]
      end
    end
    
    class VmDb
      def initialize t, k
        @db = PStore.new("db/vm-#{t}-#{k}.pstore")
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

    class VmSet
      def initialize t, k
        @db = PStore.new("db/vm-#{t}-#{k}.pstore")
      end
      def set k, *v
        if v[0]
          @db.transaction { |db| db[k] ||= []; db[k] << v[0]; db[k].uniq! }
        else
          @db.transaction { |db| db[k] }
        end
      end
    end
  end
  def self.[] k
    Vm.new(k)
  end
end
