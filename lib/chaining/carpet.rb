module HTML
  def self.[] k
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
    markdown.render(VM[k][:doc])
  end
end

module Chaining
  def self.html
    HTML
  end
end
