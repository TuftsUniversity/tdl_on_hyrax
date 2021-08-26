# frozen_string_literal: true
module MetadataMethods
  # This may be obsolete - all this information should be available from @presenter

  def self.get_metadata(fedora_obj)
    datastream = fedora_obj.datastreams["DCA-META"]

    # create the union (ie, without duplicates) of subject, geogname, persname, and corpname
    subjects = []
    union(subjects, datastream.find_by_terms_and_value(:subject))
    union(subjects, datastream.find_by_terms_and_value(:geogname))
    union(subjects, datastream.find_by_terms_and_value(:persname))
    union(subjects, datastream.find_by_terms_and_value(:corpname))

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
      subjects: subjects,
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

  def self.read_more_or_less(text, length, read_more_text = "read more", read_less_text = "read less")
    # First parameter is a string.
    # Second parameter is the length at which the output should be abbreviated with a "read more" link.
    # Optional third and fourth parameters are the text for the "read more" and "read less" links.
    # Output is a string;  if the length of the string exceeds the abbreviation length,
    # html span tags will be inserted at the abbreviation point and at the end.
    # No formatting tags like <p> or <br> are inserted;  the calling method can (must) arrange the text as needed.
    # When the "read more" link is clicked the hidden span will be shown, and there will be a "read less" link that
    # will have the opposite effect.  If no "read less" link is desired, pass "" for the fourth parameter.
    # Also include the javascript file read_more_or_less.js which has the functions that hide/show the spans.

    if text.length <= length
      text
    else
      "#{text[0..(length - 1)]}<span id=\"readmore\" style=" ">...  <a href=\"javascript:readmore();\">#{read_more_text.strip}</a></span><span id=\"readless\" style=\"display:none\">#{text[length..text.length].strip}<a href=\"javascript:readless();\">#{read_less_text.strip}</a></span>"
    end
  end
end
