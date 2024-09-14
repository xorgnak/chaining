module SESSION
  @@R = Hash.new { |h,k| h[k] = REM[k] }
  @@H = Hash.new { |h,k| h[k] = HERE[k] }
  class Session
    attr_reader :rem, :here
    def initialize k
      @key = k
      @rem = REM[k]
      @here = HERE[k]
    end
  end
  def self.[] k
    Session.new(k)
  end
end
