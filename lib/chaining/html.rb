module HTML
  class Html
    def initialize k
      @vm = VM[k]
    end
    def to_html
      
    end
  end
  def self.[] k
    Html.new(k)
  end
end
