# frozen_string_literal: true

module ImagesHelper
  # rubocop:disable Metrics/CyclomaticComplexity
  def get_rotation(image)
    return 0 if image.nil? || image.orientation.nil?
    return 0 unless image.orientation.is_a? Enumerable
    return 0 unless image.orientation[0].is_a? String

    logger.warn("An image mirroring was not handled: " + image.id) if image_mirrored? image
    extract_rotation_from_orientation(image) || 0
  end

private

  def extract_rotation_from_orientation(image)
    rotation = image.orientation[0].gsub(/[^0-9]/, '')
    return rotation.to_i unless rotation.empty?
    nil
  end

  def image_mirrored?(image)
    image.orientation[0].include?("mirror") || image.orientation[0].include?("Mirror")
  end
end
