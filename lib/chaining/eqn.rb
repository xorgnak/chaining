module EQN
  @@CA = Hash.new { |h,k| h[k] = Calc.new(k) }
  class Calc
    attr_accessor :function
    def initialize k
      @key = k
      @f = Eqn::Calculator.new("self")
    end
    def equation
      @f = Eqn::Calculator.new(@function)
    end
    def equals h={}
      equation
      h[:self] = @key
      @f.set(h)
      @f.calc
    end
  end
  
  def self.[]= k, v
    @@CA[k].function = v;
  end
  def self.[] k
    @@CA[k]
  end
  def self.keys
    @@CA.keys
  end
  def self.calc? k
    @@CA.has_key?(k) ? true : false
  end
end

EQN[:area] = 'depth * width'
EQN[:volume] = 'area * height'


