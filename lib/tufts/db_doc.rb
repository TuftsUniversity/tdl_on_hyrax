# frozen_string_literal: false

module Tufts
  module DbDoc
    include Tufts::TeiConstants

    def self.show_tei(presenter, chapter)
      result = ""
      # DIV1ID
      div2 = StreetsDiv2.where(ID: chapter)
      Rails.logger.error div2.to_s
      if div2.first.TYPE == "page"
        self.show_page(presenter, div2, chapter)
      else
        self.show_surnames(presenter, div2)
      end
    end

    def self.show_page(presenter, div2, chapter)
     Rails.logger.error "parms"
     Rails.logger.error div2.first.DIV2ID
     Rails.logger.error chapter
      div3 = StreetsDiv2.where(DIV2ID: div2.first.DIV2ID)
      frag = div3.first.XML
      Rails.logger.error "frag"
      Rails.logger.error frag
      doc = Nokogiri::XML(frag)
      hash = Hash.from_xml(doc.to_s)
      result = ""
      result += hash["div2"]["figure"]["head"].to_s
      image_pid = self.urn_to_f3_pid(hash["div2"]["figure"]["n"].to_s)
      #2.7.2 :056 > hash["div2"]["figure"]["head"]
      # => "New improved radiating hot air furnace"
      #2.7.2 :057 > hash["div2"]["figure"]["n"]
      # => "tufts:central:dca:MS102:MS102.002.006.DO.00009"
      #2.7.2 :058 > hash["div2"]["figure"]["figDesc"]
      # => "Page image of New improved radiating hot air furnace from the 1870 Boston City Directory"
      
      [result, true, image_pid]
    end

    def self.urn_to_f3_pid(urn)
      return urn if is_f3_pid?(urn)
      pid = ""
      index_of_colon = urn.rindex(':')
      pid = "tufts" + urn[index_of_colon, urn.length]
      pid
    end

    def self.is_f3_pid?(pid)
      !pid.include? 'central'
    end

    def self.show_surnames(presenter,div2)
      result = ""
      div3s = StreetsDiv3.where(DIV2ID: div2.first.DIV2ID)

      unless div3s&.nil?
        div3s.each do |node2|
          frag = node2.XML_FRAGMENT
          Rails.logger.error "frag"
          Rails.logger.error frag
          doc = Nokogiri::XML(frag)
          hash = Hash.from_xml(doc.to_s)
          entry_type = hash["div3"]["type"]
          entry_id = hash["div3"]["id"]
          #2.7.2 :063 > hash["div3"]["p"]["persName"]
          begin
            surname = hash["div3"]["p"]["persName"]["surname"]["n"] || ""
          rescue
            surname = ""
          end
          begin
            forename = hash["div3"]["p"]["persName"]["foreName"]["n"] || ""
          rescue
            forename = ""
          end

          if surname == "" && forename == ""
            orgname = ""
            begin
              orgname = hash["div3"]["p"]["orgName"]["__content__"] || ""
            rescue
              orgname = ""
            end
            if entry_type == "entry"
              result += "<h5>" + orgname.to_s + "</h5>"
            end
          else
            if entry_type == "entry"
              result += "<h5>" + surname.to_s + ", " + forename.to_s + "</h5>"
            end
          end
          begin
            occupation = hash["div3"]["p"]["rs"]["n"]
          rescue 
           occupation = ""
          end
          #if entry_type == "entry"
          #result += "<h5>" + surname.to_s + ", " + forename.to_s + "</h5>"
          #end
          result += "<dl class='dl-horizontal'>"
          result += "<dt>Type</dt>"
          result += "<dd>" + entry_type + "</dd>"
          result += "<dt>ID</dt>"
          result += "<dd>" + entry_id + "</dd>"
          if entry_type == "see.also"
            result += "<dt>Additional information</dt>"
            result += "<dd>" + doc.xpath("//text()").to_s + "</dd>"
          end
          if orgname.nil?
           
            result += "<dt>Name</dt>"
            result += "<dd>" + surname.to_s + ", " + forename.to_s + "</dd>"
          else
            unless orgname = ""
              result += "<dt>Name</dt>"
              result += "<dd>" + orgname.to_s + "</dd>"
            end
          end
          if orgname.nil?
            result += "<dt>Occupation</dt>"
            result += "<dd>" + occupation.to_s + "</dd><br>"
          end
          addresses =  self.get_addresses(hash["div3"]["p"]["address"])
          result += addresses unless addresses.nil?
          result += "</dl>"

          #2.7.2 :064 > hash["div3"]["p"]["rs"]
          # => "salesman"
          #2.7.2 :065 > hash["div3"]["p"]["address"]
          # => [{"n"=>"commercial", "street"=>" Winter"}, {"n"=>"residential.nonBoston", "name"=>["bds", {"placeName"=>"Rox"}], "street"=>" Regent"}]
        end
      end
      Rails.logger.error result 
      [result, false, nil]
    end

    def self.get_addresses(addresses)
Rails.logger.error addresses
      result = ""
      address_type = ""
      titled = false
      return if addresses.nil?
      addresses.each do |a|
        Rails.logger.error a.class.name
        Rails.logger.error a
        if a.instance_of?(Hash)
          address_type = a["n"] || ""
          if a["street"]
            address_street = a["street"]['n'] || ""
          else
            address_street = ""
          end
          result += "<dt>Address</dt><dd>&nbsp</dd>"
          result += "<dt>Type</dt>"
          result += "<dd>" + address_type + "</dd>"
          result += "<dt>Street</dt>"
          result += "<dd>" + address_street + "</dd>"
          if address_type == "residential.nonBoston" || address_type == "commercial.nonBoston"
            result += "<dt>City</dt>"
            city = a['name']
            if city.instance_of?(Hash) 
              orig_city = city
              city = city['placeName'] 
              if city.instance_of?(Hash)
                city = city['n']
              end
              if orig_city['type']
                  Rails.logger.error "where/ " + orig_city.to_s
                  city = "" if city.nil?
                  city += " Additional info: residence type " + orig_city['n']
              end
            elsif city.instance_of?(Array)
              city.each do |c|
                if c['placeName']
                  city = c['placeName']['n']
                end
                if c['type']
                  city = "" if city.nil?
                  city = city.to_s
                  city += " Additional info: residence type " + c['n'].to_s
                end
              end 
            end
            result += "<dd>" + city.to_s + "</dd><br>"
          else
            result += "<dt>City</dt>"
            result += "<dd>Boston</dd><br>"
          end
        else
          unless titled
            result += "<dt>Address</dt><dd>&nbsp</dd>"
            titled = true
          end

          element_type = a[0]
          case element_type
          when "n"
            address_type = a[1]
            result += "<dt>Type</dt>"
            result += "<dd>" + address_type + "</dd>"
          when "name"
           if address_type == "residential.nonBoston"
            result += "<dt>City</dt>"
            city = a[1][1]['placeName']['n']
            result += "<dd>" + city + "</dd>"
           else
            result += "<dt>City</dt>"
            result += "<dd>Boston</dd>"
           end
          when "street"
            begin
              address_street = a[1]["n"]
              result += "<dt>Street</dt>"
              result += "<dd>" + address_street + "</dd>"
            rescue
            end
          end
        end
      end
      Rails.logger.error "result"
      Rails.logger.error result
      return result.to_s
    end
    ####################
    # Table of Contents
    ####################
    def self.get_toc(presenter)
      chapter_list = []
      toc_result = ""
      # a = StreetsDocument.find_by(DOCUMENTID: 61)
      pid = presenter.id
      legacy_pid = presenter.solr_document._source["legacy_pid_tesim"]
      streets_document = StreetsDocument.find_by(URN: legacy_pid)
      div1s = StreetsDiv1.where(DOCUMENTID: streets_document.DOCUMENTID)
      #node_sets = xml.xpath('/TEI.2/text/body/div1')

      div1s&.each do |node|
        if node.TYPE.to_s == 'section' || node.TYPE.to_s == "part" 
          toc_result += TOC_COLLAPSE_PREDICATE_CLOSED + "<a class='collapse_tei_td' href='/streetsviewer/" + pid + "/" + pid + "/chapter/" + node.ID.to_s + "'>" + node.N.to_s + "</a>"
          toc_result += "<div class='collapse_content' style='display: none;'  >"
          toc_result2, chapter_list = get_subsection(pid, node, chapter_list)
          toc_result += toc_result2
          toc_result += "</div>"
          toc_result += TOC_SUFFIX
        else
      #    toc_result += TOC_PREDICATE + "<a href='/streetsviewer/" + pid + "/" + pid +  "/chapter/" + node.ID.to_s + "'>" + node.N.to_s + "</a>" + TOC_SUFFIX
      #    chapter_list << node.ID.to_s
        end
      end

      [toc_result, chapter_list]
    end

    def self.get_subsection(pid, node, chapter_list)
      result = ""
      id = node.DIV1ID
      # DIV1ID
      div2s = StreetsDiv2.where(DIV1ID: id)
      unless div2s&.nil?
        div2s.each do |node2|
          chapter_title = node2.N.to_s
          chapter_title.nil? ? chapter_title = '[chapter]' : chapter_title
          if node2.ID.nil?
            result << "<a href='/streetsviewer/" + pid + "/" + pid +  "/chapter/" + node.ID.to_s + "'>" + chapter_title + "</a><br/>"
            chapter_list << node.ID.to_s
          else
            result << "<a href='/streetsviewer/" + pid + "/" + pid + "/chapter/" + node2.ID.to_s + "'>" + chapter_title + "</a><br/>"
            chapter_list << node2.ID.to_s
          end
        end
      end
      [result, chapter_list]
    end
  end
end
