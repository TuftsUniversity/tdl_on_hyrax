# frozen_string_literal: false
# This file is not frozen, because something in here needs to be mutable
module EadsHelper
  def self.collection_has_online_content(collection_title, ead_id)
    solr_connection = ActiveFedora.solr.conn
    q = 'member_of_collections_ssim:"' + collection_title.gsub('"', '\\"') + '"'

    # filter the ead itself and broader meta collection, Collection Descriptions is a
    # special case as all EADs will be part of that collection since they are themselves
    # Collection Descriptions

    fq = '-id:"' + ead_id + '" AND -member_of_collections_ssim:"Collection Descriptions"'
    response = solr_connection.get('select', params: { q: q, fq: fq, rows: '2' })
    collection_length = response['response']['docs'].length

    collection_length > 0 # The EAD itself will be a member of the collection
  end

  def self.eadid(ead)
    result = ""
    url = ""
    eadid = ead.find_by_terms_and_value(:eadid)
    if eadid.present?
      first_eadid = eadid.first
      result = first_eadid.text
      url_attr = first_eadid.attribute("url")
      url = url_attr.text unless url_attr.nil?
    end

    [result, url]
  end

  def self.title(ead, include_date = true)
    full_title = ""
    raw_title = ""
    date = ""
    bulk_date = ""
    unittitles = ead.find_by_terms_and_value(:unittitle)
    if unittitles.present?
      raw_title = unittitles.first.text
      if include_date
        date, bulk_date = unitdate(ead)
        full_title = raw_title + (date.empty? ? "" : ", " + date)
      else
        full_title = raw_title
      end
    end

    [full_title, raw_title, date, bulk_date]
  end

  def self.physdesc(ead)
    result = ""
    physdescs = ead.find_by_terms_and_value(:physdesc)

    physdescs&.each do |physdesc|
      physdesc.children.each do |child|
        # <physdesc>'s text is a child;  also process text of any <extent> or other child elements
        child_text = child.text.strip
        unless child_text.empty?
          result << (result.empty? ? "" : ", ") + child_text
        end
      end
    end

    result
  end

  def self.physdesc_split(ead)
    result = ""
    physdescs = ead.find_by_terms_and_value(:physdesc)

    physdescs&.each do |physdesc|
      physdesc.children.each do |child|
        # <physdesc>'s text is a child;  also process text of any <extent> or other child elements
        child_text = child.text.strip
        next if child_text.empty?
        child_text.split(";").each do |child_text_part| # also split on semi-colons
          child_text_part_text = child_text_part.strip
          unless child_text_part_text.empty?
            result << (result.empty? ? "" : "<br>") + child_text_part_text
          end
        end
      end
    end

    result
  end

  def self.abstract(ead)
    result = ""
    abstract = ead.find_by_terms_and_value(:abstract)

    if abstract.blank?
      bioghistps = ead.find_by_terms_and_value(:bioghistp)
      result = bioghistps.first.text if bioghistps.present?
    else
      result = abstract.first.text
    end

    result
  end

  def self.get_bioghists(ead)
    result = []
    bioghists = ead.find_by_terms_and_value(:bioghist)

    result = bioghists unless bioghists.nil?

    result
  end

  def self.unitdate(ead)
    date = ""
    bulk_date = ""
    unitdates = ead.find_by_terms_and_value(:unitdate)
    unitdates&.each do |unitdate|
      datetype = unitdate.attribute("type")
      if datetype.nil? || datetype.text == "inclusive"
        date = unitdate.text
      elsif !datetype.nil? && datetype.text == "bulk"
        bulk_date = unitdate.text
      end
    end

    [date, bulk_date]
  end

  def self.unitid(ead)
    result = ""
    unitid = ead.find_by_terms_and_value(:unitid)

    result = unitid.text unless unitid.nil?

    result
  end

  def self.author(ead)
    result = ""
    persname = ead.find_by_terms_and_value(:persname)

    result = persname.text.strip unless persname.nil?

    result
  end

  def self.read_more_about(ead)
    # read_more_about ONLY returns <persname>, <corpname> or <famname> that have urls and which have been ingested.
    result = ""
    persname = ead.find_by_terms_and_value(:persname)
    corpname = ead.find_by_terms_and_value(:corpname)
    famname = ead.find_by_terms_and_value(:famname)
    name = ""
    rcr_url = ""

    if persname.present?
      name, rcr_url = parse_origination(persname)
    elsif corpname.present?
      name, rcr_url = parse_origination(corpname)
    elsif famname.present?
      name, rcr_url = parse_origination(famname)
    end

    if !name.empty? && !rcr_url.empty?
      rcr_url = "tufts:" + rcr_url
      ingested, f4_id = PidMethods.ingested?(rcr_url)
      result = "<a href=\"" + Rails.application.routes.url_helpers.hyrax_rcr_path(f4_id) + "\">" + name + "</a>" if ingested
    end

    result
  end

  def self.creator(ead)
    # creator returns <persname>, <corpname> or <famname>, with a link for ones that have urls and which have been ingested.
    result = ""
    persname = ead.find_by_terms_and_value(:persname)
    corpname = ead.find_by_terms_and_value(:corpname)
    famname = ead.find_by_terms_and_value(:famname)
    name = ""
    rcr_url = ""
    ingested = false

    if persname.present?
      name, rcr_url = parse_origination(persname)
    elsif corpname.present?
      name, rcr_url = parse_origination(corpname)
    elsif famname.present?
      name, rcr_url = parse_origination(famname)
    end

    unless name.empty?
      unless rcr_url.empty?
        rcr_url = "tufts:" + rcr_url
        ingested, f4_id = PidMethods.ingested?(rcr_url)
      end

      result = if ingested
                 "<a href=\"" + Rails.application.routes.url_helpers.hyrax_rcr_path(f4_id) + "\">" + name + "</a>"
               else
                 name
               end
    end

    result
  end

  def self.location(ead)
    result = []
    publicationstmt = ead.find_by_terms_and_value(:publicationstmt)
    publicationstmt&.children&.each do |element_child|
      if element_child.name == "publisher"
        result << element_child.text
      elsif element_child.name == "address"
        element_child.children.each do |addressline|
          text = addressline.text

          # Ignore physical <addressline> elements;  only the email address and URL are wanted.
          if text.include?("@")
            # email address
            result << text
          else
            addressline_children = addressline.element_children
            unless addressline_children.empty?
              first_child = addressline_children.first
              if first_child.name == "extptr"
                href = first_child.attribute("href")
                unless href.nil?
                  # URL
                  href_text = href.text
                  result << '<a href="' + href_text + '" target="blank">' + href_text + '</a>'
                end
              end
            end
          end
        end
      end
    end

    result
  end

  def self.langmaterial(ead)
    result = []
    langmaterials = ead.find_by_terms_and_value(:langmaterial)
    langmaterials&.each do |langmaterial|
      primary = false

      langmaterial.element_children.each do |child|
        if child.name == "language"
          primary = true
          break
        end
      end

      result << langmaterial.text unless primary
    end

    result
  end

  def self.get_arrangement(ead)
    result = []
    arrangementps = ead.find_by_terms_and_value(:arrangementp)

    arrangementps&.each do |arrangementp|
      result << arrangementp.text
    end

    result
  end

  def self.get_contents(ead)
    result = []
    scopecontentps = ead.find_by_terms_and_value(:scopecontentp)

    scopecontentps&.each do |scopecontentp|
      handle_links(scopecontentp)
      result << scopecontentp.text
    end

    result
  end

  def self.get_serieses(ead)
    result = []
    serieses = ead.find_by_terms_and_value(:series)

    if serieses.blank?
      serieses = ead.find_by_terms_and_value(:aspaceseries)

      result = serieses if serieses.present?
    else
      result = serieses
    end

    result
  end

  def self.get_series_elements(series)
    series_id = series.attribute("id").text
    did = nil
    scopecontent = nil
    c02s = []
    is_series = series.attribute("level").text == "series"

    # find the pertinent child elements: did, scopecontent and c02
    series.element_children.each do |element_child|
      childname = element_child.name
      if childname == "did"
        did = element_child
      elsif childname == "scopecontent"
        handle_links(element_child)
        scopecontent = element_child
      elsif childname == "c02" || childname == "c"
        # This method is only called from the overview page, so the series parameter
        # will be a c01 or c02 (or a c in the new ASpace EADs).  But the overview page
        # only cares about c02s because it only shows first-level serieses and second-
        # level sub-serieses.  For that reason it's never necessary to look for c03s here.
        # ASpace EADs may have third-level <c> elements when this is called for second-
        # level <c> tags and it's OK to return them because they'll be ignored.
        level = element_child.attribute("level")
        c02s << element_child if !level.nil? && level.text == "subseries"
      end
    end

    [series_id, did, scopecontent, c02s, is_series]
  end

  def self.get_series_title(did, ead_id, series_id, series_level, with_link)
    result = ""

    # process the did element
    unless did.nil?
      unittitle = ""
      unitdate = ""

      did.element_children.each do |did_child|
        childname = did_child.name
        if childname == "unittitle"
          unittitle = did_child.text
        elsif childname == "unitdate"
          datetype = did_child.attribute("type")
          unitdate = did_child.text unless !datetype.nil? && datetype.text == "bulk"
        end

        unless unittitle.empty? || unitdate.empty?
          break # found both, stop looking
        end
      end

      # This should be a link if there are no subseries elements (ie, <c02 level="subseries"> tags).
      # As of TDLR-667 all series titles will be links.
      # As of TDLR-664 with_link will be false for top-level elements which are leaf-level items.
      unless unittitle.empty?
        result = (series_level.empty? ? "" : series_level + ". ") +
                 (with_link ? "<a data-turbolinks=\"false\" href=\"" + Rails.application.routes.url_helpers.fa_series_path(ead_id, series_id) + "\">" : "") +
                 unittitle +
                 (unitdate.empty? ? "" : ", " + unitdate) +
                 (with_link ? "</a>" : "")
      end
    end

    result
  end

  def self.get_scopecontent_paragraphs(scopecontent)
    result = []

    # process the scopecontent element
    scopecontent&.element_children&.each do |scopecontent_child|
      childname = scopecontent_child.name
      if childname == "p"
        handle_links(scopecontent_child)
        result << scopecontent_child.text
      elsif childname == "note"
        scopecontent_child.element_children.each do |note_child|
          if note_child.name == "p"
            handle_links(note_child)
            result << note_child.text
          end
        end
      end
    end

    result
  end

  def self.handle_links(element)
    handle_these_links(element, :archref)
    handle_these_links(element, :extref)
    handle_these_links(element, :extptr)
  end

  def self.handle_these_links(element, tag)
    element.search(tag).each do |found|
      text = found.text                # returns empty string if tag has no text
      href = found.attribute("href")   # returns nil if tag has no href attribute
      title = found.attribute("title") # returns nil if tag has no title attribute
      the_text = !text.empty? ? text : (!title.nil? ? title : (!href.nil? ? href : ''))
      the_href = !href.nil? ? href : (!text.empty? ? text : (!title.nil? ? title : ''))
      found.content = '<a href="' + the_href + '" target="blank">' + the_text + '</a>'
    end
  end

  def self.get_paragraphs(element, can_contain_links = false)
    result = []

    unless element.nil?
      element.element_children.each do |element_child|
        next unless element_child.name == "p"
        handle_links(element_child) if can_contain_links
        result << element_child.text
      end

      result << element.text if result.empty? # No <p> was found, so use the full text of the element.
    end

    result
  end

  def self.get_bioghist_head_and_paragraphs(element)
    head = ""
    paragraphs = []

    element&.element_children&.each do |element_child|
      if element_child.name == "head"
        head = element_child.text
      elsif element_child.name == "p"
        paragraphs << element_child.text
      end
    end

    [head, paragraphs]
  end

  def self.search_field_for(tag_name)
    { "subject" => "subject",
      "geogname" => "geographic_name",
      "genreform" => "genreform",
      "title" => "title",
      "persname" => "persname",
      "corpname" => "corpname",
      "famname" => "family_name" }[tag_name]
  end

  def self.get_subjects_and_names(ead)
    subjects_genres = []
    related_names = []
    controlaccesses = ead.find_by_terms_and_value(:controlaccess)

    controlaccesses&.each do |controlaccess|
      controlaccess.element_children.each do |element_child|
        childname = element_child.name

        if ["persname", "corpname", "famname", "subject", "geogname", "genreform", "title"].include?(childname)
          child_text = element_child.text
          # child_id = element_child.attribute("id")
          # child_url = (child_id.nil? ? "" : ("tufts:" + child_id.text))

          unless child_text.empty?
            search_path = Rails.application.routes.url_helpers.search_catalog_path(q: child_text, search_field: search_field_for(childname))
            search_tag = '<a data-turbolinks="false" href="' + search_path + '">' + child_text + '</a>'

            if ["persname", "corpname", "famname"].include?(childname)
              # ingested = false
              # ingested, f4_id = PidMethods.ingested?(child_url) unless child_url.empty?
              # related_names << (ingested ? '<a data-turbolinks="false" href="' + Rails.application.routes.url_helpers.hyrax_rcr_path(f4_id) + '">' : '') + child_text + (ingested ? '</a>' : '')
              related_names << search_tag
            else
              subjects_genres << search_tag
            end
          end
        end
      end
    end

    [subjects_genres, related_names]
  end

  def self.get_related_material(ead)
    result = []
    relatedmaterialps = ead.find_by_terms_and_value(:relatedmaterialp)

    relatedmaterialps&.each do |relatedmaterialp|
      handle_links(relatedmaterialp)
      result << relatedmaterialp.text
    end

    result
  end

  def self.get_separated_material(ead)
    result = []
    separatedmaterialps = ead.find_by_terms_and_value(:separatedmaterialp)

    separatedmaterialps&.each do |separatedmaterialp|
      handle_links(separatedmaterialp)
      result << separatedmaterialp.text
    end

    result
  end

  def self.get_access_restrictions(ead)
    result = []
    accessrestrictps = ead.find_by_terms_and_value(:accessrestrictp)
    descgrpaccessrestrictps = ead.find_by_terms_and_value(:descgrpaccessrestrictp)

    accessrestrictps&.each do |accessrestrictp|
      result << accessrestrictp.text
    end

    descgrpaccessrestrictps&.each do |descgrpaccessrestrictp|
      result << descgrpaccessrestrictp.text
    end

    result
  end

  def self.get_use_restrictions(ead)
    result = []
    userestrictps = ead.find_by_terms_and_value(:userestrictp)
    descgrpuserestrictps = ead.find_by_terms_and_value(:descgrpuserestrictp)

    userestrictps&.each do |userestrictp|
      result << userestrictp.text.sub(Rails.configuration.use_restrict_text_match, Rails.configuration.use_restrict_text_replace)
    end

    descgrpuserestrictps&.each do |descgrpuserestrictp|
      result << descgrpuserestrictp.text.sub(Rails.configuration.use_restrict_text_match, Rails.configuration.use_restrict_text_replace)
    end

    result
  end

  def self.get_preferred_citation(ead)
    result = []
    preferciteps = ead.find_by_terms_and_value(:prefercitep)
    descgrppreferciteps = ead.find_by_terms_and_value(:descgrpprefercitep)

    # Prefercite doesn't appear in our EADs but someday it could.
    preferciteps&.each do |prefercitep|
      result << prefercitep.text
    end

    descgrppreferciteps&.each do |descgrpprefercitep|
      result << descgrpprefercitep.text
    end

    result
  end

  def self.get_processing_notes(ead)
    result = []
    processinfops = ead.find_by_terms_and_value(:processinfop)

    processinfops&.each do |processinfop|
      result << processinfop.text
    end

    result
  end

  def self.get_acquisition_info(ead)
    result = []
    acqinfops = ead.find_by_terms_and_value(:acqinfop)

    acqinfops&.each do |acqinfop|
      result << acqinfop.text
    end

    result
  end

  def self.get_custodial_history(ead)
    result = []
    custodhistps = ead.find_by_terms_and_value(:custodhistp)

    custodhistps&.each do |custodhistp|
      result << custodhistp.text
    end

    result
  end

  def self.get_phystech(ead)
    result = []
    phystechps = ead.find_by_terms_and_value(:phystechp)
    descgrpphystechps = ead.find_by_terms_and_value(:descgrpphystechp)

    phystechps&.each do |phystechp|
      result << phystechp.text
    end

    descgrpphystechps&.each do |descgrpphystechp|
      result << descgrpphystechp.text
    end

    result
  end

  def self.get_accruals(ead)
    result = []
    accrualsps = ead.find_by_terms_and_value(:accrualsp)

    accrualsps&.each do |accrualsp|
      result << accrualsp.text
    end

    result
  end

  def self.get_appraisal(ead)
    result = []
    appraisalps = ead.find_by_terms_and_value(:appraisalp)

    appraisalps&.each do |appraisalp|
      result << appraisalp.text
    end

    result
  end

  def self.get_altformavail(ead)
    result = []
    altformavailps = ead.find_by_terms_and_value(:altformavailp)

    altformavailps&.each do |altformavailp|
      handle_links(altformavailp)
      result << altformavailp.text
    end

    result
  end

  def self.get_originalsloc(ead)
    result = []
    originalslocps = ead.find_by_terms_and_value(:originalslocp)

    originalslocps&.each do |originalslocp|
      result << originalslocp.text
    end

    result
  end

  def self.get_otherfindaid(ead)
    result = []
    otherfindaidps = ead.find_by_terms_and_value(:otherfindaidp)

    otherfindaidps&.each do |otherfindaidp|
      handle_links(otherfindaidp)
      result << otherfindaidp.text
    end

    result
  end

  def self.get_sponsor(ead)
    result = ""

    sponsor = ead.find_by_terms_and_value(:sponsor)

    result = sponsor.text unless sponsor.nil?

    result
  end

  def self.get_series(ead, item_id)
    # The ead param is not a Nokogiri::XML::Element, so .ng_xml must be called.
    # Find new ASpace series tags like <c id="aspace_1ba86c68818ab59b72d6fd01b6c15017" ...>
    # or old CIDER series tags like <c01 id="MS001.001" ...>
    nodes = ead.ng_xml.xpath("//*[@id='" + item_id + "']")
    return [nil, ''] if nodes.empty?

    series = nodes[0]
    # In old CIDER EADs the unitid is the item's id
    # New ASpace EADs have the unitid in a node like <did><unitid>MS001.001</unitid>...</did>
    nodes = series.xpath("//c[@id='" + item_id + "']/did/unitid")
    unitid = (nodes.empty? ? item_id : nodes[0].text)

    # Construct series_level out of the unitid which will be like "XX123.018.006.002"
    # Remove everything before the first period.
    if unitid =~ /^[^\.]+(.+)$/
      series_level = Regexp.last_match(1)
      # Remove all leading zeros.
      found = ""
      found = series_level.sub!(/\.0+/, ".") until found.nil?
      # Remove the leading period.
      series_level.sub!(/^./, "")
    else
      series_level = ''
    end

    [series, series_level]
  end

  def self.get_series_info(series)
    did = nil
    scopecontent = nil
    unittitle = ""
    unitdate = ""
    unitdate_bulk = ""
    creator = ""
    unitid = ""
    physdesc = ""
    title = ""
    paragraphs = []
    series_items = []
    series_langmaterial = []
    series_arrangement = []
    series_access_restrict = []
    series_use_restrict = []
    series_phystech = []
    series_prefercite = []
    series_processinfo = []
    series_acquisition_info = []
    series_custodhist = []
    series_accruals = []
    series_appraisal = []
    series_separated_material = []
    series_subjects_genres = []
    series_related_names = []
    series_related_material = []
    series_alt_formats = []
    series_originals_loc = []
    series_other_finding_aids = []

    unless series.nil?
      # find the pertinent child elements: did, scopecontent, etc
      series.element_children.each do |element_child|
        childname = element_child.name
        if childname == "did"
          did = element_child
        elsif childname == "scopecontent"
          scopecontent = element_child
        elsif childname == "accessrestrict"
          series_access_restrict = get_paragraphs(element_child)
        elsif childname == "userestrict"
          series_use_restrict = get_paragraphs(element_child)
        elsif childname == "phystech"
          series_phystech = get_paragraphs(element_child)
        elsif childname == "prefercite"
          series_prefercite = get_paragraphs(element_child)
        elsif childname == "arrangement"
          series_arrangement = get_paragraphs(element_child)
        elsif childname == "processinfo"
          series_processinfo = get_paragraphs(element_child)
        elsif childname == "acqinfo"
          series_acquisition_info = get_paragraphs(element_child)
        elsif childname == "custodhist"
          series_custodhist = get_paragraphs(element_child)
        elsif childname == "accruals"
          series_accruals = get_paragraphs(element_child)
        elsif childname == "appraisal"
          series_appraisal = get_paragraphs(element_child)
        elsif childname == "separatedmaterial"
          series_separated_material = get_paragraphs(element_child, true)
        elsif childname == "relatedmaterial"
          series_related_material = get_paragraphs(element_child, true)
        elsif childname == "altformavail"
          series_alt_formats = get_paragraphs(element_child, true)
        elsif childname == "originalsloc"
          series_originals_loc = get_paragraphs(element_child)
        elsif childname == "otherfindaid"
          series_other_finding_aids = get_paragraphs(element_child, true)
        elsif childname == "c02" || childname == "c03" || childname == "c"
          # The series could be a <c01 level="series"> with c02 children, or
          # it could be a <c02 level="subseries"> with c03 children.
          series_items << element_child
        elsif childname == "controlaccess"
          element_child.element_children.each do |element_grandchild|
            grandchildname = element_grandchild.name

            if ["persname", "corpname", "famname", "subject", "geogname", "genreform", "title"].include?(grandchildname)
              grandchild_text = element_grandchild.text
              # grandchild_id = element_grandchild.attribute("id")
              # grandchild_url = (grandchild_id.nil? ? "" : "tufts:" + grandchild_id.text)

              unless grandchild_text.empty?
                search_path = Rails.application.routes.url_helpers.search_catalog_path(q: grandchild_text, search_field: search_field_for(grandchildname))
                search_tag = '<a data-turbolinks="false" href="' + search_path + '">' + grandchild_text + '</a>'

                if ["persname", "corpname", "famname"].include?(grandchildname)
                  # ingested = false
                  # ingested, f4_id = PidMethods.ingested?(grandchild_url) unless grandchild_url.empty?
                  # series_related_names << (ingested ? '<a data-turbolinks="false" href="' +
                  #   Rails.application.routes.url_helpers.hyrax_rcr_path(f4_id) + '">' : '') +
                  #   grandchild_text + (ingested ? '</a>' : '')
                  series_related_names << search_tag
                else
                  series_subjects_genres << search_tag
                end
              end
            end
          end
        end
      end

      # process the did element
      did&.element_children&.each do |did_child|
        childname = did_child.name
        if childname == "unittitle"
          unittitle = did_child.text
        elsif childname == "unitdate"
          datetype = did_child.attribute("type")
          if datetype.nil? || datetype.text == "inclusive"
            unitdate = did_child.text
          elsif !datetype.nil? && datetype.text == "bulk"
            unitdate_bulk = did_child.text
          end
        elsif childname == "physdesc"
          did_child.children.each do |physdesc_child|
            # <physdesc>'s text is a child;  also process text of any <extent> or other child elements
            physdesc_child_text = physdesc_child.text.strip
            unless physdesc_child_text.empty?
              physdesc << (physdesc.empty? ? "" : ", ") + physdesc_child_text
            end
          end
        elsif childname == "unitid"
          unitid = did_child.text
        elsif childname == "langmaterial"
          series_langmaterial = get_paragraphs(did_child)
        elsif childname == "origination"
          did_child.children.each do |grandchild|
            creator << grandchild.text.strip if grandchild.name == "persname"
          end
        end
      end

      # process the scopecontent element
      paragraphs = get_scopecontent_paragraphs(scopecontent)

      title = (unittitle.empty? ? "" : unittitle + (unitdate.empty? ? "" : ", " + unitdate))
    end

    [title,
     unittitle,
     unitdate,
     unitdate_bulk,
     creator,
     physdesc,
     series_langmaterial,
     paragraphs,
     series_arrangement,
     series_access_restrict,
     series_use_restrict,
     series_phystech,
     series_prefercite,
     series_processinfo,
     series_acquisition_info,
     series_custodhist,
     series_accruals,
     series_appraisal,
     series_separated_material,
     series_subjects_genres,
     series_related_names,
     series_related_material,
     series_alt_formats,
     series_originals_loc,
     series_other_finding_aids,
     series_items,
     unitid]
  end

  def self.get_series_item_info(item, pid)
    # title = ""
    paragraphs = []
    labels = []
    values = []
    next_level_items = []
    did = nil
    dao = nil
    daogrp = nil
    scopecontent = nil
    unittitle = ""
    unitdate = ""
    physloc = ""
    physloc_orig = ""
    physloc_unprocessed = ""
    physdesc = ""
    creator = ""
    page = ""
    thumbnail = ""
    thumbnail_path = ""
    access_restrict = ""
    available_online = false
    can_request = false
    external_page = ""
    # external_page_title = ""

    item_id = item.attribute("id").text
    item_url_id = item.attribute("id").text
    item_type = item.attribute("level").text
    item_url = ""

    item.element_children.each do |item_child|
      childname = item_child.name
      if childname == "did"
        did = item_child
      elsif childname == "daogrp"
        daogrp = item_child
      elsif childname == "scopecontent"
        scopecontent = item_child
      elsif childname == "accessrestrict"
        access_restrict = get_paragraphs(item_child).join("  ") # expecting a string, not an array of paragraphs
      elsif childname == "c03" || childname == "c04" ||
            childname == "c05" || childname == "c06" ||
            childname == "c07" || childname == "c08" ||
            childname == "c09" || childname == "c10" ||
            childname == "c11" || childname == "c12" || childname == "c"
        next_level_items << item_child
      end
    end

    did&.element_children&.each do |did_child|
      childname = did_child.name
      if childname == "unittitle"
        unittitle = did_child.children.first.text
        did_child.children.each do |grandchild|
          next unless grandchild.name == "unitdate"
          datetype = grandchild.attribute("type")
          unless !datetype.nil? && datetype.text == "bulk"
            unitdate = grandchild.text
            break
          end
        end
      elsif childname == "unitdate"
        datetype = did_child.attribute("type")
        unitdate = did_child.text unless !datetype.nil? && datetype.text == "bulk"
      elsif childname == "unitid"
        # In ASpace EADs the human-readable item id is in <c><did><unitid>... instead of the id attribute of the <c id=...>
        item_id = did_child.text
      elsif childname == "physloc"
        can_request = true
        physloc = did_child.text
        physloc_orig = did_child.text
      elsif childname == "physdesc"
        did_child.children.each do |physdesc_child|
          # <physdesc>'s text is a child;  also process text of any <extent> or other child elements
          physdesc_child_text = physdesc_child.text.strip
          unless physdesc_child_text.empty?
            physdesc << (physdesc.empty? ? "" : ", ") + physdesc_child_text
          end
        end
      elsif childname == "container"
        # ASpace puts the location in <container label=""> rather than <physloc>
        unless did_child.attribute("label").nil?
          can_request = true
          physloc = did_child.attribute("label").text
          physloc_orig = did_child.attribute("label").text
        end
      elsif childname == "origination"
        did_child.children.each do |grandchild|
          creator << grandchild.text.strip if grandchild.name == "persname"
        end
      elsif childname == "dao"
        dao = did_child
      end
    end

    unless physloc.empty?
      # If the location is like: "Mixed Materials (39090015754001g)" or "Mixed Materials [39090015754001g]",
      # remove all but "39090015754001g using regex match"
      physloc_regex = /^(.*?[\(\[])?(.*?)([\)\]])?$/

      physloc = Regexp.last_match(2) if physloc =~ physloc_regex

      physloc_orig = Regexp.last_match(2) if physloc_orig =~ physloc_regex
    end

    # CIDER EADs have a <daogrp> element.
    unless daogrp.nil?
      daogrp.element_children.each do |daogrp_child|
        next unless daogrp_child.name == "daoloc"
        daoloc_audience = daogrp_child.attribute("audience")
        daoloc_label = daogrp_child.attribute("label")
        daoloc_href = daogrp_child.attribute("href")

        if !daoloc_audience.nil? && daoloc_audience.text == "internal"
          # an audience="internal" attribute in a daoloc tag means this item is in the Dark Archive;
          # leave page and thumbnail_path = "" so that values will not be returned for them
          # and so that the href will not be included in title.  Set physloc to the dark
          # archive message.
          can_request = true
          physloc = "Dark Archive"
        elsif !daoloc_label.nil? && !daoloc_href.nil?
          daoloc_label_text = daoloc_label.text
          daoloc_href_text = daoloc_href.text

          if daoloc_label_text == "page"
            page = daoloc_href_text
          elsif daoloc_label_text == "thumbnail"
            thumbnail = daoloc_href_text
          end
        end
      end

      unless page.empty?
        available_online, f4_id, f4_thumb_path, model = PidMethods.ingested?(page)
        if available_online
          page = f4_id
          # only show thumbnail if EAD says to, but the pid in the EAD will be wrong.
          thumbnail_path = f4_thumb_path unless thumbnail.empty?
        end
      end
    end

    # ASpace EADs have a <dao> element.
    if dao.nil?
      if physloc.empty? && (item_type != "subseries" || next_level_items.empty?)
        # An item that has neither dao nor location, or a subseries that has no children can be requested,
        # but a subseries that is not empty can NOT be requested
        can_request = true
      end
    else
      dao_href = dao.attribute("href")
      if !dao_href.nil? && dao_href.text.include?("darkarchive")
        # In an ASpace EAD, an href="https://darkarchive.lib.tufts.edu/" attribute in the <dao> element
        # means that this item is in the Dark Archive;  Set physloc to the DA message.
        # Note that if the URL for DA ever changes, all the EADs would not necessarily have to change
        # since the <dao> href value is never displayed or used as a link in TDL.
        can_request = true
        physloc = "Dark Archive"
      else
        # ASpace EADs lack the <daogrp><daoloc> page and thumbnail attributes, so compute them thusly
        # (and searching in solr for the item by its handle, which is in the dao's href):
        available_online, f4_id, f4_thumb_path, model = PidMethods.ingested?(dao_href.text) unless dao_href.nil?

        if available_online
          page = f4_id
          thumbnail_path = f4_thumb_path unless model == "Tei" # unless ["Tei", "Foo"].include?(model)
        elsif dao_href.nil?
          # It's not in Solr, and it's not in darkarchive, and it has no href, so it must be unprocessed.
          can_request = true
          physloc_unprocessed = "DCA Digital Storage"
        else
          # It's not in Solr, and it's not in darkarchive, but it has an href, so it must be a non-TDL link.
          external_page = dao_href.text
          available_online = true
          # dao_title = dao.attribute("title")
          # external_page_title = (dao_title.nil? ? unittitle : dao_title.text)
        end
      end
    end

    if available_online
      if !page.empty?
        item_url = Rails.application.routes.url_helpers.send("hyrax_#{model.underscore}_path", page) # underscore also downcases
      elsif !external_page.empty?
        item_url = external_page
      end
    elsif item_type == "subseries"
      item_url = Rails.application.routes.url_helpers.fa_series_path(pid, item_url_id)
    end

    title = ''
    if item_url.present?
      title = "<a "
      title += "data-turbolinks=\"false\" " if external_page.empty?
      title += "href=\"#{item_url}\""
      title += " target=\"blank\"" unless external_page.empty?
      title += '>'
    end
    title += unittitle
    title += " #{unitdate}" unless unitdate.empty? || unittitle.end_with?(unitdate)
    title += "</a>" if item_url.present?

    unless physloc.empty?
      labels << "Location"
      values << physloc
    end

    unless physloc_unprocessed.empty?
      labels << "Location"
      values << physloc_unprocessed
    end

    unless item_id.empty? || item_id.start_with?("aspace")
      labels << "Item ID"
      values << item_id
    end

    unless item_type.empty?
      labels << "Type"
      values << item_type.capitalize
    end

    unless access_restrict.empty?
      labels << "Access"
      values << access_restrict
    end

    paragraphs = get_scopecontent_paragraphs(scopecontent) unless scopecontent.nil?

    [unitdate, creator, physloc_orig, physdesc, access_restrict, item_id, title, paragraphs, labels, values, item_url, thumbnail_path, available_online, can_request, next_level_items]
  end

  def self.parse_origination(node)
    name = ""
    rcr_url = ""

    first_element = node.first

    unless first_element.nil?
      name = first_element.text
      first_element_id = first_element.attribute("id")

      rcr_url = first_element_id.text unless first_element_id.nil?
    end

    [name, rcr_url]
  end

  def self.find_indexable_fields(id, results)
    document_fedora = ActiveFedora::Base.find(id)
    document_ead = Datastreams::Ead.from_xml(document_fedora.file_sets.first.original_file.content)
    document_ead = document_ead.ng_xml.remove_namespaces!

    archdescs = document_ead.xpath('//ead/archdesc')

    return false if archdescs.empty?

    archdescs.each do |archdesc|
      find_controlaccess(archdesc, results)
      find_dsc(archdesc, results)
    end

    # results is a hash table whose keys are field names and values are hash tables with field values as both key and value, like:
    # {"genreform"=>{"Diaries"=>"Diaries", "Sketchbooks"=>"Sketchbooks"}, "subject"=>{"Adolescence"=>"Adolescence", "Advertising"=>"Advertising"}}.
    # The reason to have hash tables within hash tables is for best insertion performance and so that field values aren't duplicated, but
    # it's a little confusing as a returned result, so convert the inner hash tables to arrays so that the above example would look like"
    # {"genreform"=>["Diaries", "Sketchbooks"], "subject"=>["Adolescence", "Advertising"]}.
    results.each do |field_name, field_values|
      results[field_name] = field_values.keys
    end

    true
  end

  def self.find_controlaccess(node, results)
    controlaccess = node.xpath('./controlaccess')

    return false if controlaccess.empty?

    # puts('  ' + node.name + (node.name == 'archdesc' ? '' : (' ' + node['level'] + ' ' + node['id'])))
    find_tag(controlaccess, 'persname', results)
    find_tag(controlaccess, 'corpname', results)
    find_tag(controlaccess, 'famname', results)
    find_tag(controlaccess, 'geogname', results)
    find_tag(controlaccess, 'genreform', results)
    find_tag(controlaccess, 'subject', results)
    find_tag(controlaccess, 'title', results)

    true
  end

  def self.find_dsc(node, results)
    dsc = node.xpath('./dsc')

    return false if dsc.empty?

    unless find_series(dsc, results)  # ASpace series (c)
      find_series(dsc, results, 1)    # non-ASpace series (c01, c02...)
    end

    true
  end

  def self.find_series(node, results, level = 0)
    if level == 0
      level_string = ''
      next_level = 0
    else
      level_string = format('%02d', level)
      next_level = level + 1
    end

    serieses = node.xpath('./c' + level_string)

    return false if serieses.empty?

    serieses.each do |series|
      find_controlaccess(series, results)
      find_series(series, results, next_level)
    end

    true
  end

  def self.find_tag(node, tag, results)
    subnodes = node.xpath('./' + tag)

    return false if subnodes.empty?

    # puts('    ' + tag)
    tag_hash = results[tag]

    if tag_hash.nil?
      tag_hash = {}
      results[tag] = tag_hash
    end

    subnodes.each do |subnode|
      # puts('      ' + subnode.text)
      tag_hash[subnode.text] = subnode.text
    end

    true
  end
end
