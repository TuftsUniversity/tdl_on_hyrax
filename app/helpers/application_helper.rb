module ApplicationHelper
  TYPES = {
    'Rcr' => '/assets/rcr/rcr.png',
    'Ead' => '/assets/ead/file_box.png',
    'VotingRecord' => '/assets/datasets/datasets.png',
    'GenericObject' => '/assets/generic/generic.png'
  }.freeze

  def render_thumbnail_by_type(document, image_options = {}, url_options = {})
    value = get_image_tag(document, image_options)

    return unless value

    if url_options == false
      Deprecation.warn(self, "passing false as the second argument to render_thumbnail_tag is deprecated. Use suppress_link: true instead. This behavior will be removed in Blacklight 7")
      url_options = { suppress_link: true }
    end

    if url_options[:suppress_link]
      value
    else
      link_to_document document, value, url_options
    end
  end

  def get_image_tag(document, image_options = {})
    type = document['has_model_ssim']
    value = TYPES[type.first]

    if value.nil?
      url = thumbnail_url(document)
      value = image_tag(url, image_options) if url.present?
    else
      value = image_tag(value, image_options)
    end

    value
  end
end
