class Document < ApplicationRecord
  has_paper_trail
  has_many_attached :embeds

  before_save :set_embeds

  private

  def set_embeds
    return if content.blank?

    nokogiri_html = Nokogiri::HTML.parse(content)
    sgids = nokogiri_html.css('figure').map do |figure|
      trix_attachment = JSON.parse(figure['data-trix-attachment'])
      trix_attachment['sgid']
    end
    blobs = sgids.map { |sgid| ActiveStorage::Blob.find_signed(sgid) }

    self.embeds = blobs - embeds.map(&:blob)
  end
end
