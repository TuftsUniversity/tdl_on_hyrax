# frozen_string_literal: true

require 'mime/types'

module HyraxHelper
  include ::BlacklightHelper
  include Hyrax::BlacklightOverride
  include Hyrax::HyraxHelperBehavior

  ##
  # Creates an array download bar link data, based on controller name.
  #
  # @param {str} controller_name
  #   The name of the current controller.
  #
  # @return {arr}
  #   An array of hashes with link data, for use in _download_options view.
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/PerceivedComplexity
  # rubocop:disable Metrics/AbcSize
  def download_link_info(controller_name)
    download_links = []
    return download_links unless @presenter
    link_var = @presenter.respond_to?(:solr_document) && !@presenter.solr_document.nil? ? @presenter.solr_document._source["downloadable_tesim"] : nil
    link_var = [] if link_var.nil?
    return download_links if @presenter.class.to_s == "Hyrax::AdminStatsPresenter" || @presenter.class.to_s == "Hyrax::Admin::DashboardPresenter" || link_var.include?("no-link")
    return download_links if @presenter.nil?
    unless @presenter.class.to_s != "Hyrax::Admin::DashboardPresenter" &&
           @presenter.class.to_s != "Hyrax::UserProfilePresenter" &&
           !@presenter.solr_document.nil? &&
           !@presenter.solr_document._source['workflow_state_name_ssim'].nil? &&
           @presenter.solr_document._source['workflow_state_name_ssim'].any? &&
           (@presenter.solr_document._source['workflow_state_name_ssim'].include? "unpublished")
      # Add the transcript link in any controller.
      download_links << transcript_link(@presenter.transcript_id) if @document_tei.present? && @presenter.class.to_s != "Hyrax::TeiPresenter"

      case controller_name
      when 'audios'
        download_links << add_to_list_link
        download_links << audio_link(@presenter.media_id)
      when 'images'
        download_links << add_to_list_link
        archival_id = @presenter.solr_document._source['hasRelatedImage_ssim']
        download_links << (current_user && current_user.role?(:archivist) ? high_res_image_link(archival_id) : low_res_image_link(archival_id))
      when 'generic_objects'
        download_links << add_to_list_link
        download_links << generic_link(@presenter.solr_document._source['hasRelatedMediaFragment_ssim'])
      when 'teis'
        download_links << add_to_list_link
      when 'pdfs'
        download_links << add_to_list_link
        download_links << pdf_link(@presenter.solr_document._source['hasRelatedMediaFragment_ssim'])
      when 'rcrs'
        download_links << eac_link(@presenter.rcr_id) if @document_rcr.present? && @presenter.rcr_id
      when 'videos'
        download_links << add_to_list_link
        download_links << video_link(@presenter.media_id)
      end
    end

    download_links
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/PerceivedComplexity

  def get_link_to_primary_binary(obj)
    model = obj.class.to_s.downcase
    file_set = obj.file_sets[0]

    case model
    when 'audio'
      "https://dl.tufts.edu/downloads/#{file_set.id}?file=mp3"
    when 'image'
      Riiif::Engine.routes.url_helpers.image_url(file_set.files.first.id, host: 'https://dl.tufts.edu', size: "400,")
    when 'pdf'
      "https://dl.tufts.edu/downloads/#{file_set.id}"
    else
      ''
    end
  end

  ##
  # The info for the "Add to List" link.
  #
  # @return {hash}
  #   The info for the "Add to List" link.
  def add_to_list_link
    {
      icons: 'glyphicon glyphicon-plus-sign',
      url: '',
      text: 'Add to List',
      class: 'list-add'
    }
  end

  ##
  # The info for "Download File" link.
  #
  # @param {str} file_id
  #   The file id of the file.
  #
  # @return {hash}
  #   The infor for the "Download File" link.
  def generic_link(file_id)
    related_object = ActiveFedora::Base.find(file_id)

    # I don't think its correct but occassionally we get an array here from AF
    related_object = related_object.first if related_object.is_a? Array

    content_type = related_object.mime_type

    # look up mime type against data source to get an file extension
    mime_types = MIME::Types[content_type]

    if mime_types.any?
      file_extension = MIME::Types[content_type].first.extensions.first
    else
      # handle cases where mime type can not be found in data source
      content_type = content_type.split('/')[1]
      file_extension = content_type
    end

    {
      icons: 'glyphicon glyphicon-file glyph-left',
      url: "#{hyrax.download_path(file_id)}?filename=#{@presenter.id}.#{file_extension}",
      text: 'Download File',
      label: "Download File"
    }
  end

  ##
  # The info for "Download Audio" link.
  #
  # @param {str} media_id
  #   The media id of the mp3.
  #
  # @return {hash}
  #   The infor for the "Download Audio" link.
  def audio_link(media_id)
    {
      icons: 'glyphicon glyphicon-headphones glyph-left',
      url: build_link(media_id, 'mp3'),
      text: 'Download Audio File',
      label: "Audio: #{media_id.first}"
    }
  end

  ##
  # The info for "Download EAC" link.
  #
  # @param {str} rcr_id
  #   The rcr id for the eac.
  #
  # @return {hash}
  #   The infor for the "Download EAC" link.
  def eac_link(rcr_id)
    {
      icons: 'glyphicon glyphicon-file',
      url: build_link(rcr_id, 'xml'),
      text: 'Download EAC',
      label: "EAC: #{rcr_id.first}"
    }
  end

  def vtt_link(id)
    "#{hyrax.download_path(id)}?filename=#{id}.txt"
  end

  ##
  # The info for "Download PDF" link.
  #
  # @param {?} ?
  #   ??
  # @return {hash}
  #   The info for the "Download PDF" link.
  def pdf_link(pdf_id)
    {
      icons: 'glyphicon glyphicon-file',
      url: build_link(pdf_id, 'pdf'),
      text: 'Download PDF',
      label: "PDF: #{pdf_id.first}"
    }
  end

  ##
  # The info for "Download Low-Resolution Image" link.
  #
  # @param {arr} file_set id
  #   Id of the file_set that the image is in.
  #
  # @return {hash}
  #   The info for the "Download Low-Resolution Image" link.
  def low_res_image_link(image_id)
    file_set_id = @presenter.solr_document._source["file_set_ids_ssim"].first
    file_set = FileSet.find(file_set_id)
    download_link = Riiif::Engine.routes.url_helpers.image_url(file_set.files.first.id, host: request.base_url, size: "400,")
    {
      icons: 'glyphicon glyphicon-picture glyph-left',
      url: download_link,
      text: 'Download Low-Resolution Image',
      label: "Image: #{image_id.first}"
    }
  end

  ##
  # The info for "Download High-Resolution Image" link.
  #
  # @param {arr} file_set id
  #   Id of the file_set that the image is in.
  #
  # @return {hash}
  #   The info for the "Download High-Resolution Image" link.
  def high_res_image_link(image_id)
    file_set_id = @presenter.solr_document._source["file_set_ids_ssim"].first
    {
      icons: 'glyphicon glyphicon-picture glyph-left',
      url: hyrax.download_path(file_set_id).to_s,
      text: 'Download High-Resolution Image',
      label: "Image: #{image_id.first}"
    }
  end

  ##
  # The info for the "Download Transcript" link.
  #
  # @param {str} transcript_id
  #   The transcript id.
  #
  # @return {hash}
  #   The info for the "Download Transcript" link.
  def transcript_link(transcript_id)
    {
      icons: 'glyphicon glyphicon-file',
      url: build_link(transcript_id, 'xml'),
      text: 'Download Transcript',
      label: "Transcript: #{transcript_id.first}"
    }
  end

  ##
  # The info for "Download Video" link.
  #
  # @param {str} media_id
  #   The media id of the mp4.
  #
  # @return {hash}
  #   The info for the "Download Video" link.
  def video_link(media_id)
    {
      icons: 'glyphicon glyphicon-film glyph-left',
      url: "#{hyrax.download_path(media_id, file: 'mp4')}&filename=#{@presenter.id}.mp4",
      text: 'Download Video File',
      label: "Video: #{media_id.first}"
    }
  end

  private

    ##
    # Builds a download and attaches the appropriate filename.
    #
    # @param {str/arr} id
    #   The id of the object.
    # @param {str} file_ext
    #   The file extension to use.
    #
    # @return {str}
    #   The download uri.
    def build_link(id, file_ext)
      "#{hyrax.download_path(id)}?filename=#{@presenter.id}.#{file_ext}"
    end
end
