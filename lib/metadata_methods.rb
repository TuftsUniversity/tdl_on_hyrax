# frozen_string_literal: true
module MetadataMethods
  # This may be obsolete - all this information should be available from @presenter
  # read_more_or_less is used in /app/views/shared/_metadata.html.erb. The other methods appear to not be used.

  def self.get_metadata(fedora_obj)
    datastream = fedora_obj.datastreams["DCA-META"]
    data_hash = build_hash(datastream)

    # create the union (ie, without duplicates) of subject, geogname, persname, and corpname
    data_hash[:subjects] = []
    union(data_hash[:subjects], datastream.find_by_terms_and_value(:subject))
    union(data_hash[:subjects], datastream.find_by_terms_and_value(:geogname))
    union(data_hash[:subjects], datastream.find_by_terms_and_value(:persname))
    union(data_hash[:subjects], datastream.find_by_terms_and_value(:corpname))

    data_hash
  end

  def self.build_hash(datastream)
    {
      titles: datastream.find_by_terms_and_value(:title),
      creators: datastream.find_by_terms_and_value(:creator),
      dates: datastream.find_by_terms_and_value(:dateCreated),
      descriptions: datastream.find_by_terms_and_value(:description),
      sources: datastream.find_by_terms_and_value(:source2),
      citable_urls: datastream.find_by_terms_and_value(:identifier),
      citations: datastream.find_by_terms_and_value(:bibliographicCitation),
      publishers: datastream.find_by_terms_and_value(:publisher),
      genres: datastream.find_by_terms_and_value(:genre),
      types: datastream.find_by_terms_and_value(:type2),
      formats: datastream.find_by_terms_and_value(:format2),
      rights: datastream.find_by_terms_and_value(:rights),
      temporals: datastream.find_by_terms_and_value(:temporal)
    }
  end

  def self.union(array1, array2)
    # Params are two arrays of Nokogiri elements.  Add elements of array2 to array1 and return array1.
    # Leave out duplicate elements, where e.g. <dcadesc:geogname>Somerville (Mass.)</dcadesc:geogname> and
    # <dcadesc:subject>Somerville (Mass.)</dcadesc:subject> are defined as duplicate (i.e., their .text is ==).

    array2.each do |element2|
      dup = false

      array1.each do |element1|
        if element1 == element2
          dup = true
          break
        end
      end

      array1 << element2 unless dup
    end

    array1
  end

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
