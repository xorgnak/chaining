
module COIN
  
  class Bank
    attr_accessor :value
    def initialize seed
      @seed = seed
      @wallet = PStore.new("db/bank-wallet-#{seed}.pstore")
      @rate = PStore.new("db/bank-rate-#{seed}.pstore")
      @info = PStore.new("db/bank-info-#{seed}.pstore")
      @value = 1.to_f
    end
    def info *h
      if h[0]
        @info.transaction { |db| h[0].each_pair { |k,v| db[k] = v } }
      else
        h = {}
        @info.transaction { |db| db.keys.each { |e| h[e] = db[e] } }
        return h
      end
    end
    def seed
      @seed
    end
    def rates
      @rate.transaction { |db| db.keys }
    end
    def rate n, *a
      if a[0]
        @rate.transaction { |db| db[n] = a[0].to_f }
      else
        @rate.transaction { |db| db[n].to_f }
      end
    end
    def fund n
      @wallet.transaction { |db| x = db['bank'].to_f; db['bank'] = x + n.to_f; }
    end
    def burn n
      @wallet.transaction { |db| x = db['bank'].to_f; db['bank'] = x - n.to_f; }
    end    
    def held u
      @wallet.transaction { |db| db[u].to_f }
    end    
    def worth u
      (held(u).to_f * ( 1 / @value.to_f )).to_f
    end
    def [] k
      @wallet.transaction { |db| db[k].to_f }
    end
    def credit u, n
      @wallet.transaction { |db| x = db[u].to_f; db[u] = x + n.to_f; }
    end
    def debit u, n
      @wallet.transaction { |db| x = db[u].to_f; db[u] = x - n.to_f; }
    end
    def transaction h={}
      @wallet.transaction do |ddb|
        f = ddb[h[:from]].to_f
        t = ddb[h[:to]].to_f
        ddb[h[:to]] = t + h[:amount].to_f
        ddb[h[:from]] = f - h[:amount].to_f
      end
    end
    def to_h
      h = { rates: {}, wallets: {} }
      @wallet.transaction { |db| db.keys.each { |e| h[:wallets][e] = db[e].to_f } }
      @rate.transaction { |db| db.keys.each { |e| h[:rates][e] = db[e].to_f } }
      return h
    end
  end

  @@BANK = Hash.new { |h,k| h[k] = Bank.new(k) }

  def self.bank
    @@BANK
  end
  
  @@CENTRAL = @@BANK[:central]
  
  if @@CENTRAL["bank"] == 0
    @@CENTRAL.fund 100
  end
  
  def self.central
    @@CENTRAL
  end
  
  def self.swap h={}
    f = h[:from]
    t = h[:to]
    m = %[#{f[:amount]}#{f[:bank]} -> #{t[:amount]}#{t[:bank]}]
    x = Digest::SHA2.hexdigest("#{f[:user]} #{m} #{t[:user]} at #{Time.now.utc.to_f * 1000}")
    @@COIN[t[:bank]].block({ from: "bank", to: t[:user], amount: t[:amount].to_f, memo: %[IMPORT #{m}], swap: x })
    @@COIN[f[:bank]].block({ from: f[:user], to: "bank", amount: (0 - f[:amount].to_f), memo: %[EXPORT #{m}], swap: x })
    @@COIN[f[:bank]].bank.rate(t[:bank], t[:amount].to_f / f[:amount].to_f)
    @@COIN[t[:bank]].bank.rate(f[:bank], f[:amount].to_f / t[:amount].to_f)
  end
  
  class Chain
    def initialize seed
      @seed = seed
      @db = PStore.new("db/chain-db-#{seed}.pstore")
      @blocks = PStore.new("db/chain-blocks-#{seed}.pstore")
      @db.transaction { |db| @nonce = db[:nonce] || 0 }
      @here = Digest::SHA2.hexdigest("#{seed}#{@nonce}")
      @bank = COIN.bank[seed]
    end
    def bank
      @bank
    end
    def debug
      { seed: @seed, nonce: @nonce, here: @here }
    end
    def nonce
      @nonce
    end
    def here
      @here
    end
    def [] k
      @db.transaction { |db| db[k] }
    end
    def blocks k
      @blocks.transaction { |db| db[k] }
    end
    def block h={}
      ret = 200
      b = Block.new(@seed, @here, h)
      @db.transaction do |db|
        @nonce += b.nonce
        db[:nonce] = @nonce;
        db[@here] = b.to_h;
      end
      @bank.transaction h
      @blocks.transaction { |db|
        if !db.key?(h[:to]); db[h[:to]] = []; end; db[h[:to]] << @here
        if !db.key?(h[:from]); db[h[:from]] = []; end; db[h[:from]] << @here
      }
      hh = { status: ret, here: @here, data: h }
      @here = b.next
      return hh
    end
    def send f, t, a, m
      block(from: f, to: t, amount: a, memo: m)
    end
    def mint u, a, m
      bank.fund(a)
      a.times { block(from: 'bank', to: u, amount: a, memo: m) }
    end
    def mine u, f
      t = DateTime.now
      block(from: 'bank', to: u, amount: 1, memo: %[Mine reward: #{t.strftime("%Q").to_i} #{t.to_s}], fingerprint: f)
    end
    def to_h
      h = {}
      @db.transaction { |db| db.keys.each { |e| if e != :nonce; h[e] = db[e]; end } }
      return h
    end
    def each_pair &b
      @db.transaction { |db| db.keys.each { |e| if e != :nonce; b.call(e, db[e]); end } }
    end
    class Block
      attr_reader :next, :nonce 
      def initialize seed, this, h={}
        @nonce = rand(5..15)
        @next = Digest::SHA2.hexdigest("#{seed}#{@nonce}")
        @h = {}
        @h[:epoch] = DateTime.now.strftime("%Q").to_i
        @h[:here] = @next
        @h[:nonce] = @nonce
        @h[:data] = h
      end
      def to_h
        @h
      end
    end
  end
  
  @@COIN = Hash.new { |h,k| h[k] = Chain.new(k.to_s) }
  
  @@COINS = PStore.new("db/coins.pstore")
  @@COINS.transaction { |db| db.keys.each { |e| @@COIN[e] } }
  
  def self.[] k
    @@COINS.transaction { |db| db[k] ||= {} }
    @@COIN[k]
  end
  def self.[]= k, v
    @@COINS.transaction { |db| db[k] = v }
  end
  def self.keys
    @@COIN.keys
  end

  def self.wallet c, u
    h = {}
    h =  { balance: @@COIN[c].bank[u], transactions: {} }
    @@COIN[c].blocks(u).to_a.each { |e| h[:transactions][e] = @@COIN[c][e] }
    return h
  end
  
end


module Chaining
  def self.coin *k, &b
    if block_given?
      [k].flatten.each { |e| b.call(COIN[e]) }
    else
      if k.length > 0
        COIN[k[0]]
      else
        COIN
      end
    end 
  end
  def self.coins
    COIN.keys
  end
end


#COIN["COIN"]["block"]
#COIN["COIN"].blocks["user"]
#COIN["COIN"].bank["user"]
#COIN["COIN"].bank.transaction({ from: "from", to: "to", amount: 1, memo: %[Hello, you.] })
#COIN.swap({ from: { bank: "COIN", user: "from", amount: 1 }, to: { bank: "COIN", user: "to", amount: 1 } })
