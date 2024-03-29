# frozen_string_literal: true
#
# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
Mime::Type.register "application/n-triples", :nt
Mime::Type.register "application/ld+json", :jsonld
Mime::Type.register "text/turtle", :ttl
Mime::Type.register 'application/x-endnote-refer', :endnote

# add mime types for download lookups
MIME::Types.add(MIME::Type.new(["audio/x-wav", %w[wav]]))
MIME::Types.add(MIME::Type.new(["audio/x-wave", %w[wav]]))
