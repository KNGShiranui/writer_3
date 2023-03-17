# frozen_string_literal: true

class Documents::ChangesController < ApplicationController
#   def show
#     @document = Document.find(params[:document_id])
#     @version = @document.versions.find(params[:id])
#     # binding.pry
#   end
# end

  def show
    @document = Document.find(params[:document_id])
    @version = @document.versions.find(params[:id])
    # binding.pry
    if params[:before] && params[:after]
      markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
      html_before = markdown.render(params[:before])
      html_after = markdown.render(params[:after])
      p html_before
      p html_after
      @diff = Markdiff::Differ.new.render(html_before, html_after)
    end
  end
end