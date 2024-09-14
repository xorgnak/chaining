module DECK
  @@D = Hash.new { |h,k| Deck.new(k) }
  class Deck
    attr_accessor :suits, :cards, :faces, :special
    attr_reader :deck, :burn
    def initialize k
      @key = k
    end
    def deal *n
      if @deck.length + n[0] || 1 < 0
        shuffle!
      end
      a = []
      (n[0] || 1).times { x = @deck.shift; a << x; @burn << x }
      return a
    end
    
    def standard
      @deck = []
      @burn = []
      @suits = [:heart, :diamond, :club, :spade]
      @faces = [:jack, :queen, :king, :ace]
      @cards = (2..10)
      @special = ["red joker", "black joker"]      
    end

    def poker
      @deck = []
      @burn = []
      @suits = [:heart, :diamond, :club, :spade]
      @faces = [:jack, :queen, :king, :ace]
      @cards = (2..10)
      @special = []
    end

    def tarot
      @deck = []
      @burn = []
      @suits = [:cups, :coins, :acorn, :sword]
      @faces = [:page, :jack, :queen, :king, :ace]
      @cards = (1..10)
      @special = []
      21.times { |t| @special << "minor acarna #{t}" }
    end
    
    def shuffle!
      @deck = []
      @suits.each do |suit|
        @cards.each do |card|
          @deck << { suit: suit, card: card }
        end
        @faces.each do |card|
          @deck << { suit: suit, card: card }
        end        
      end
      @special.each do |card|
        @deck << { suit: "#", card: card }
      end
      @deck.shuffle!
    end
  end
  def self.[] k
    @@D[k]
  end
end
