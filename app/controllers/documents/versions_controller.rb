# frozen_string_literal: true

class Documents::VersionsController < ApplicationController
  def show
    @document = Document.find(params[:document_id])
    @version = @document.versions.find(params[:id])
  end

  def update  
    @document = Document.find(params[:document_id])
    @version = @document.versions.find(params[:id])
    # binding.pry
    if @version.next.present?
      @document = @version.next.reify
      @document.save!
    end
    redirect_to document_path(@document)
  end
end
