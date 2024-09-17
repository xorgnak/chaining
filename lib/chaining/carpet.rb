module HTML
  def self.[] k
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
    markdown.render(ERB.new(VM[k][:doc]).result(binding))
  end
end

module Chaining
  def self.html
    HTML
  end
end
