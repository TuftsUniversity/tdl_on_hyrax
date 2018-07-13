# Generated via
#  `rails generate hyrax:work Image`
module Hyrax
  class ImagePresenter < GenericWorkPresenter

    # IIIF metadata for inclusion in the manifest
    #  Called by the `iiif_manifest` gem to add metadata
    #
    # iiif_manifest doesn't allow for blank fields, so this
    #   removes any of them before moving on.
    #
    # @return [Array] array of metadata hashes
    def manifest_metadata
      super.delete_if { |data| data["value"].blank? }
    end

  end
end
