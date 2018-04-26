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
  def download_link_info(controller_name)
    download_links = []

    # Add the transcript link in any controller.
    download_links << transcript_link(@presenter.transcript_id) if @document_tei.present?

    case controller_name
    when 'audios'
      download_links << audio_link(@presenter.media_id)
    when 'images'
      download_links << add_to_list_link
      download_links << low_res_image_link(@presenter.solr_document._source['hasRelatedImage_ssim'])
    when 'rcrs'
      download_links << eac_link(@presenter.rcr_id) if @document_rcr.present?
    when 'videos'
      download_links << video_link(media_id)
    end

    download_links
  end
  # rubocop:enable Metrics/CyclomaticComplexity

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
      blank: false
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
      url: hyrax.download_path(media_id, file: "mp3"),
      text: 'Download Audio File'
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
      url: hyrax.download_path(rcr_id),
      text: 'Download EAC'
    }
  end

  ##
  # The info for "Download Low-Resolution Image" link.
  #
  # @param {arr} file_set
  #   The file_set that the image is in.
  #
  # @return {hash}
  #   The infor for the "Download Low-Resolution Image" link.
  def low_res_image_link(file_set)
    {
      icons: 'glyphicon glyphicon-picture glyph-left',
      url: Riiif::Engine.routes.url_helpers.image_path(file_set, 'full'),
      text: 'Download Low-Resolution Image'
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
      url: hyrax.download_path(transcript_id),
      text: 'Download Transcript'
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
      url: hyrax.download_path(media_id, file: "mp4"),
      text: 'Download Video File'
    }
  end
end
