module ACT
  @@DO = {}
  def self.[] x
    a = []
    @@DO.each_pair { |k,v|
      if m = Regexp.new(k.to_s).match(x);
        a << v.call(m);
      end
    }
    return a.flatten.uniq.compact
  end
  def self.on k, &v
    @@DO[k] = v
  end
  def self.keys
    @@DO.keys
  end
end

ACT.on("now") { |m| Time.now.to_s }
#ACT.on("date") { |m| ACT['now'] }
#ACT.on("time") { |m| ACT['now'] }
ACT.on("things") { |m| HERE["my session"].keys }
ACT.on('put (?<thing>.*) on (?<location>.*)\.') { |m| HERE["my session"][m[:thing]] = m[:location]; %[#{m[:thing]}: #{m[:location]}] }
ACT.on('(?<thing>.*) are on (?<location>.*)\.') { |m| HERE["my session"][m[:thing]] = m[:location]; %[#{m[:thing]}: #{m[:location]}] }
ACT.on('where are my (?<thing>.*)\?') { |m| x = HERE["my session"][m[:thing]]; %[#{m[:thing]}: #{x}] }
ACT.on('where are the (?<thing>.*)\?') { |m| x = HERE["my session"][m[:thing]]; %[#{m[:thing]}: #{x}] }
ACT.on('where is my (?<thing>.*)\?') { |m| x = HERE["my session"][m[:thing]]; %[#{m[:thing]}: #{x}] }
ACT.on('where is the (?<thing>.*)\?') { |m| x = HERE["my session"][m[:thing]]; %[#{m[:thing]}: #{x}] }

#ACT["What time is it?"]
