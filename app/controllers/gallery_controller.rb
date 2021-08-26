# frozen_string_literal: true
class GalleryController < ApplicationController
  def image_gallery
    @document_fedora = Tei.find(params[:id])

    title = @document_fedora.title.first
    xml = Nokogiri::XML(@document_fedora.file_sets.first.original_file.content)
    xml.remove_namespaces! unless xml.nil?
    node_sets = xml.xpath('//figure')
    total_length = node_sets.length

    figures = []

    start = Integer(params[:start])
    end_figure = Integer(params[:number])

    unless node_sets.nil?
      node_sets = node_sets.slice(start, end_figure)
      node_sets.each do |node|
        image_pid = PidMethods.urn_to_f3_pid(node[:n])
        image_title = ""
        full_title = ""
logger.info("Gallery searching for Image: #{image_pid}")
        @image = Image.where(legacy_pid_tesim: image_pid)

        @image = @image.first
logger.info("Gallery Image not found: #{@image.nil?}")
        image_id = @image.thumbnail_id unless @image.nil?
        object_id = @image.id
        begin
          image_title = @image.title.first unless @image.title.nil? #image_metadata[:titles].nil? ? "" : image_metadata[:titles].first
          full_title = image_title
          image_title = image_title.slice(0, 17) + '...' if image_title.length > 20
    #      image_url = Riiif::Engine.routes.url_helpers.image_url(file_set.files.first.id, host: request.base_url, size: "400,")
        rescue NoMethodError
          image_title = ""
        end

        figures << { pid: image_id, object_pid: object_id, caption: image_title, full_title: full_title }
      end
    end

    render json: { figures: figures, count: total_length, title: "Illustrations from the " + title.to_s }
  end

  def image_overlay
    @document_fedora = Image.find(params[:id])
    title = @document_fedora.title.first
    temporal = @document_fedora.temporal.empty? ? "" : @document_fedora.temporal.first
    description = @document_fedora.description.empty? ? "" : @document_fedora.description.first 
    pid = params[:id]
    item_link = '/concern/images/' + pid
    #image_url = '/downloads/' + @document_fedora.thumbnail_id + '?file=thumbnail'
    image_url = Riiif::Engine.routes.url_helpers.image_url(@document_fedora.file_sets.first.files.first.id, host: request.base_url, size: "550,")

    render json: { back_url: "#", item_title: title, item_date: temporal, image_url: image_url, item_link: item_link, item_description: description, width: "", height: "" }
  end
end
