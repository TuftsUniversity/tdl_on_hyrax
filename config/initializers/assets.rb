# frozen_string_literal: true
#
# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
Rails.application.config.assets.precompile += %w[object_css/teif3.css
                                                 object_css/tei.scss
                                                 object_css/rcr.scss
                                                 object_css/transcript.scss
                                                 object_css/generic_object_overrides.css
                                                 object_css/toc.css
                                                 object_css/voting_record.css bookreader.js]
