# frozen_string_literal: false
module Tufts
  module Renderers
    class MergedAttributeRenderer < Hyrax::Renderers::LinkedAttributeRenderer
      ##
      # @function
      # Takes multiple hashes of field information and builds one <ul> out of it.
      #
      # @param {hash} fields
      #   {field_name: [values], 2nd_field_name: [values], etc}
      def initialize(fields, options)
        @fields = fields
        # Let most of the class act as if the first field is the main field - for labeling and other purposes
        @field, @values = fields.first
        @options = options
      end

      def render
        markup = ''

        return markup if @fields.empty?

        markup << %(<tr><th>#{label}</th>\n<td><ul class='tabular'>)
        @fields.each do |f, v|
          @field = f
          attributes = microdata_object_attributes(f).merge(class: "attribute attribute-#{f}")
          Array(v).each do |value|
            markup << "<li#{html_attributes(attributes)}>#{attribute_value_to_html(value.to_s)}</li>"
          end
        end

        markup << %(</ul></td></tr>)
        markup.html_safe # rubocop:disable Rails/OutputSafety
      end
    end
  end
end
