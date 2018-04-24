module HyraxHelper
  include ::BlacklightHelper
  include Hyrax::BlacklightOverride
  include Hyrax::HyraxHelperBehavior

  ##
  # The info for the "Add to List" link.
  #
  # @return {hash}
  #   The info for the "Add to List" link.
  def add_to_list_link
    {
      icons: 'glyphicon glyphicon-plus-sign',
      url: '',
      text: 'Add to List'
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
  # Creates the download bar links, based on controller name.
  #
  # @param {str} controller_name
  #   The name of the current controller.
  #
  # @return {arr}
  #   An array of hashes with link information.
  def download_link_info(controller_name)
    download_links = []

    case controller_name
    when 'audios'
      if @document_tei.present?
        download_links << transcript_link(@presenter.transcript_id)
      end
      download_links << {
        icons: 'glyphicon glyphicon-headphones glyph-left',
        url: hyrax.download_path(@presenter.media_id, file: "mp3"),
        text: 'Download Audio File'
      }
    when 'images'
      file_set = @presenter.solr_document._source['hasRelatedImage_ssim']
      download_links << add_to_list_link
      download_links << {
        icons: 'glyphicon glyphicon-picture glyph-left',
        url: Riiif::Engine.routes.url_helpers.image_path(file_set, 'full'),
        text: 'Download low-resolution image'
      }
    when 'rcrs'
      if @document_rcr.present?
        download_links << {
          icons: 'glyphicon glyphicon-file',
          url: hyrax.download_path(@presenter.rcr_id),
          text: 'Download EAC'
         }
      end
    when 'videos'
      if @document_tei.present?
        download_links << transcript_link(@presenter.transcript_id)
      end
      download_links << {
        icons: 'glyphicon glyphicon-film glyph-left',
        url: hyrax.download_path(@presenter.media_id, file: "mp4"),
        text: 'Download Video File'
      }
    else
      # Rubocop requires an else block.
    end # end case controller

    download_links
  end # end download_link_info
end # end HyraxHelper