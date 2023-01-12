# frozen_string_literal: true
module MetadataMethods
  # read_more_or_less is used in /app/views/shared/_metadata.html.erb.

  def self.read_more_or_less(text, length, opts = {})
    # First parameter is a string.
    # Second parameter is the length at which the output should be abbreviated with a "read more" link.
    # Optional third on whether to use turn urls into links.
    # Output is a string;  if the length of the string exceeds the abbreviation length,
    # html span tags will be inserted at the abbreviation point and at the end.
    # No formatting tags like <p> or <br> are inserted;  the calling method can (must) arrange the text as needed.
    # When the "read more" link is clicked the hidden span will be shown, and there will be a "read less" link that
    # will have the opposite effect.  If no "read less" link is desired, pass "" for the fourth parameter.
    # Also include the javascript file read_more_or_less.js which has the functions that hide/show the spans.
    opts = {
      auto_link: false
    }.merge(opts)

    if (text_length = text.length) <= length && opts[:auto_link]
      ActionController::Base.helpers.auto_link(text)
    elsif text_length <= length
      text
    elsif opts[:auto_link]
      # We don't what to seperate a link into two spots so we split on whitespace
      split_index = find_closest_white_space_index(text, length - 1)
      front_text = ActionController::Base.helpers.auto_link(text[0..split_index])
      back_text = ActionController::Base.helpers.auto_link(text[split_index + 1..text.length])
      "#{front_text}<span id=\"readmore\" style=" ">...  <a href=\"javascript:readmore();\">read more</a></span>" \
      "<span id=\"readless\" style=\"display:none\">#{back_text}<a href=\"javascript:readless();\">read less</a></span>"
    else
      "#{text[0..(length - 1)]}<span id=\"readmore\" style=" ">...  <a href=\"javascript:readmore();\">read more</a></span>" \
      "<span id=\"readless\" style=\"display:none\">#{text[length..text.length].strip}<a href=\"javascript:readless();\">read less</a></span>"
    end
  end

  def self.find_closest_white_space_index(text, index) # rubocop:disable  Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
    # blank returns true if character is whitespace
    return index if text[index].blank?

    index_shift = 1
    # I assume length is expensive method. Let's cache the value. It wont change.
    length = text.length
    while index - index_shift >= 0 || index + index_shift < length
      # Checks to the left of start postion
      return (index - index_shift) if index - index_shift >= 0 && text[index - index_shift].blank?
      # Checks to the right of the start postion
      return (index + index_shift) if index + index_shift < length && text[index + index_shift].blank?

      index_shift += 1
    end
    # What to return if text has no whitesapce?
    index
  end
end
