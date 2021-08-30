# frozen_string_literal: true
class GalleryController < ApplicationController
  def image_gallery
    @document_fedora = Tei.find(params[:id])
    @figures = []
    title = @document_fedora.title.first
    xml = Nokogiri::XML(@document_fedora.file_sets.first.original_file.content)
    xml&.remove_namespaces!
    @node_sets = xml.xpath('//figure')

    render json: { figures: generate_figures, count: @node_sets.length, title: "Illustrations from the " + title.to_s }
  end

  def image_overlay
    @document_fedora = Image.find(params[:id])
    title = @document_fedora.title.first
    temporal = @document_fedora.temporal.empty? ? "" : @document_fedora.temporal.first
    description = @document_fedora.description.empty? ? "" : @document_fedora.description.first
    pid = params[:id]
    item_link = '/concern/images/' + pid
    # image_url = '/downloads/' + @document_fedora.thumbnail_id + '?file=thumbnail'
    image_url = Riiif::Engine.routes.url_helpers.image_url(@document_fedora.file_sets.first.files.first.id, host: request.base_url, size: "550,")

    render json: { back_url: "#", item_title: title, item_date: temporal, image_url: image_url, item_link: item_link, item_description: description, width: "", height: "" }
  end

  private

    def generate_figures
      @node_sets&.slice(Integer(params[:start]), Integer(params[:number]))&.each do |node|
        image = get_image(node)
        logger.info("Gallery Image not found") if image.nil?
        image_id = image.thumbnail_id unless image.nil?

        image_title = ""
        full_title = ""
        begin
          full_title = image.title.first unless image.title.nil? # image_metadata[:titles].nil? ? "" : image_metadata[:titles].first
          image_title = full_title.slice(0, 17) + '...' if full_title.length > 20
          # image_url = Riiif::Engine.routes.url_helpers.image_url(file_set.files.first.id, host: request.base_url, size: "400,")
        end

        @figures << { pid: image_id, object_pid: image.id, caption: image_title, full_title: full_title }
      end
    end

    def get_image(node)
      image_pid = PidMethods.urn_to_f3_pid(node[:n])
      logger.info("Gallery searching for Image: #{image_pid}")
      Image.where(legacy_pid_tesim: image_pid).first
    end
end
