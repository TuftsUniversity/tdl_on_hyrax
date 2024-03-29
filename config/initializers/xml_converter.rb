# frozen_string_literal: true
module ActiveSupport
  class XMLConverter
    private

      def become_content?(value)
        value['type'] == 'file' || (value['__content__'] && (value.keys.size == 1 && value['__content__'].present?))
      end
  end
end
