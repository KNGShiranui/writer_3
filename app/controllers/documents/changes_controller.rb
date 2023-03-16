# frozen_string_literal: true

class Documents::ChangesController < ApplicationController
  def show
    @document = Document.find(params[:document_id])
    @version = @document.versions.find(params[:id])
    # binding.pry
  end
end
