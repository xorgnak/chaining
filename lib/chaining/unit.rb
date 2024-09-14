module UNIT
  def self.[] k
    U.new(k)
  end
  class U
    def initialize k
      @k = k.to_s
      @u = Unit.new(@k)
    end
    def to_unit
      @unit
    end
    def [] k
      @u.convert_to(k.to_s)
    end
  end

end
