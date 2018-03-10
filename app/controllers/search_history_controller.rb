class SearchHistoryController < ApplicationController
  include Blacklight::SearchHistory
  helper BlacklightAdvancedSearch::RenderConstraintsOverride
  helper BlacklightRangeLimit::ViewHelperOverride
  helper RangeLimitHelper
end
