module KEY
  @@K = {}
  def self.[]= k,v
    @@K[k.to_sym] = v
  end
  def self.[] k
    ERB.new(@@K[k.to_sym]).result(binding)
  end
  def self.include? k
    @@K.keys.include?(k.to_sym) ? true : false
  end
end

KEY[:hello] = %[Hello!]
