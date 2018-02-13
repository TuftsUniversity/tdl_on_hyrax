module WithLimitedFileSets
  extend ActiveSupport::Concern
  included do
    class_attribute :max_allowable_file_sets
    self.max_allowable_file_sets = 1
  end
end
