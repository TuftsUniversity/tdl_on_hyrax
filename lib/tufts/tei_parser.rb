# frozen_string_literal: true
require 'easy_logging'

module Tufts
  module TeiParser
    extend Tufts::TeiToc
    include EasyLogging
    # Global pre-configuration for every Logger instance
    EasyLogging.log_destination = 'tei_parsing.log'
    EasyLogging.level = Logger::DEBUG

    def self.show_tei(fedora_obj, tei, chapter)
      # if there's no chapter specified show the cover
      chapter = "title" if chapter.nil?

      # special case show the cover
      show_tei_cover(fedora_obj, tei, chapter) if chapter == "title" || (chapter.start_with? "front")

      # special case show the back cover
      show_tei_backpage(fedora_obj, tei, chapter) if chapter.starts_with? "back"
      show_tei_page(fedora_obj, tei, chapter)
    end

    ####################
    # TEI Cover Page
    ####################
    def self.show_tei_cover(_fedora_obj, tei, chapter)
      result = ""

      # tei cover will be one of these 2 elements.
      node_sets = tei.xpath('/TEI.2/text/front/div1|/TEI.2/text/front/titlePage')

      result += show_tei_table_start

      if chapter == 'title'
        node = node_sets.first
        node = node_sets.to_ary[1] if !node.nil? && node['type'] == 'frontispiece'
        result << ctext(node)
      else
        node_sets&.each do |n|
          result << ctext(n) if chapter == 'title' || (chapter != "title" && chapter == n['id'])
        end
      end

      result += show_tei_table_end

      result
    end
    private_class_method :show_tei_cover

    ####################
    # TEI Back Page
    ####################

    def self.show_tei_backpage(_fedora_obj, tei, chapter)
      result = ""
      result += show_tei_table_start

      node_sets = tei.xpath('/TEI.2/text/back/div1')
      node_sets&.each do |node|
        result << ctext(node) if chapter == 'title' || (chapter != "title" && chapter == node['id'])
      end

      result += show_tei_table_end
      result
    end
    private_class_method :show_tei_backpage

    ####################
    # TEI Tables
    ####################
    def self.show_tei_table_start
      '<table cellpadding="2" cellspacing="5" class="noborder bookviewer_table"><tbody>'
    end
    private_class_method :show_tei_table_start

    def self.show_tei_table_end
      '</tbody></table>'
    end
    private_class_method :show_tei_table_end

    # recursive function to walk the title page stick everything into divs
    def self.ctext(el)
      return "" if el.nil?
      return el.text if el.text?
      result = []
      el.children.each do |sel|
        if sel.element?
          type = sel[:type]
          if sel.name == 'figure'
            pid = PidMethods.urn_to_f3_pid(sel['n'])
            image = Image.where(legacy_pid_tesim: pid)
            image = image.first
            image_id = image.thumbnail_id unless image.nil?
            result.push("<br/><br/><img src='/downloads/#{image_id}?file=thumbnail'>")
          else
            result.push("<div class='" + sel.name + " " + (type.nil? ? "" : type) + "'>")
          end
        end
        result.push(ctext(sel))
        next unless sel.element?
        result.push("</div>") unless sel.name == 'figure'
      end
      result.join
    end
    private_class_method :ctext

    def self.render_image_page(_fedora_obj, tei, chapter)
      result = ""

      node_sets = tei.xpath(
        '//body/div1/div2[@id="' +
          chapter +
          '"]/p/figure/head|//body/div1[@id="' +
          chapter +
          '"]/figure/head'
      )

      node_sets&.each do |node|
        result += "<h6>" + node + "</h6><br/>"
      end

      node_sets = tei.xpath(
        '//body/div1/div2[@id="' +
          chapter +
          '"]/p/figure|//body/div1[@id="' +
          chapter +
          '"]/figure'
      )

      node_sets&.each do |node|
        pid = PidMethods.urn_to_f3_pid(node['n'])
        image = Image.where(legacy_pid_tesim: pid)
        image = image.first
        base_url = "https://dl.tufts.edu"
        iiif_url = Riiif::Engine.routes.url_helpers.image_url(image.file_sets[0].files.first.id, host: base_url, size: "400,")
        #          result += ("<br/><br/><img src='/downloads/#{image_id}?file=thumbnail'>")
        result += "<br/><br/><img src='#{iiif_url}'>"
        #          result += ("<br/><br/><img alt=\"\" src=\"" + "/file_assets/" + pid + "\"></img>")
      end

      node_sets = tei.xpath(
        '//body/div1/div2[@id="' +
          chapter +
          '"]/p/figure/figDesc|//body/div1[@id="' +
          chapter +
          '"]/figure/figDesc'
      )

      node_sets&.each do |node|
        result += ("<p>" + node + "</p>")
      end

      result
    end
    private_class_method :render_image_page

    def self.render_pb(node)
      result = if node['n'].nil?
                 ""
               else
                 "<p>" + node['n'] + "</p>"
               end
      result
    end
    private_class_method :render_pb

    def self.get_foot_note(child)
      footnotes = ""
      note_id = child['n'].nil? ? child['id'] : child['n']
      if note_id.present?
        result = "<a href='#'>[" + note_id + "]</a>&nbsp;"
      else
        note_id = ""
      end
      footnotes = "<p>[" + note_id + "] " + child.text.to_s.strip + "</p>" if child.name == "note"

      [result, footnotes]
    end
    private_class_method :get_foot_note

    def self.get_block_quote(node)
      result = '<blockquote>'

      children = node.children
      children.each do |child|
        result += "<p>" + child.text + "</p>"
      end
      result += "</blockquote>"
      result
    end
    private_class_method :get_block_quote

    def self.show_tei_page(fedora_obj, tei, chapter)
      # render the requested chapter.
      # NOTE: should break this out into a method probably.
      result = ""
      footnotes = ""
      node_sets = tei.xpath('//body/div1[@id="' + chapter + '"]/head|//body/div1/div2[@id="' + chapter + '"]/head')
      node_sets&.each do |node|
        result += "<h6>" + node + "</h6><br/>"
      end

      # render the bibl
      node_sets = tei.xpath('//body/div1[@id="' + chapter + '"]/head|//body/div1/div2[@id="' + chapter + '"]/bibl')
      node_sets&.each do |node|
        result += "<p class=" + node.name + ">" + node + "</p>"
      end

      # peek ahead and see if this is an image book if not render it as a standard text book.
      # result +="<p> is chapter image book : "+ (chapter_image_book?(fedora_obj, chapter).to_s) +"</p>"
      result += if chapter_image_book?(fedora_obj, tei, chapter)
                  render_image_page(fedora_obj, tei, chapter)
                else
                  render_text_page(tei, chapter, footnotes)
                end
      result
    end
    private_class_method :show_tei_page

    def self.chapter_image_book?(_fedora_obj, tei, chapter)
      node_sets = tei.xpath(
        '//body/div1[@id="' +
          chapter +
          '"]/figure|//body/div1[@id="' +
          chapter +
          '"]/p|//body/div1/div2[@id="' +
          chapter +
          '"]/p|//body/div1[@id="' +
          chapter +
          '"]/quote|//body/div1/div2[@id="' +
          chapter +
          '"]/quote'
      )
      node_sets&.each do |node|
        return node.parent['rend'] == 'page-image'
      end
      false
    end
    private_class_method :chapter_image_book?

    def self.render_text_page(tei_xml, chapter, footnotes)
      result = show_tei_table_start
      node_sets = tei_xml.xpath(
        '//body/div1[@id="' +
          chapter +
          '"]/p|//body/div1/div2[@id="' +
          chapter +
          '"]/p|//body/div1[@id="' +
          chapter +
          '"]/quote|//body/div1/div2[@id="' +
          chapter +
          '"]/quote|//body/div1/div2[@id="' +
          chapter +
          '"]|//body/div1[@id="' +
          chapter +
          '"]'
      )
      in_left_td = true
      unless node_sets.nil?
        node_sets = node_sets.first.children if node_sets.first.name == "div1"
        node_sets.each do |node|
          node_text = node.text.to_s.strip
          next if node_text.blank?

          result += "<tr>"
          result += "<td class=pagenumber>"
          logger.warn "node name #{node.name}"
          case node.name
          when "pb"
            result += render_pb(node)
          when "quote"
            if in_left_td
              result += switch_to_right
              result += "<td>"
              in_left_td = false
            end

            result += get_block_quote(node)
          when "p"
            # if we're in the left close it.
            if in_left_td
              result += switch_to_right
              in_left_td = false
            end

            result += "<td>"

            result_p, in_left_td2, footnotes2 = render_page_p(node, in_left_td)
            in_left_td = in_left_td2
            footnotes += footnotes2
            result += result_p
          when "table"
            result += render_table(node, in_left_td)
          when "list"
            result += "<p></p>"
          when "div2"
            if in_left_td
              result += switch_to_right
              in_left_td = false
            end
            if chapter.include? 'fig'
              result += ctext(node)
            else
              begin
                ls = node.children
                ls.each do |l|
                  # result += "<p>" + l.text.to_s.strip + "</p>"
                  # uncommenting this causes double printing in concise
                  # encyclopedia, i don't know of a counter test case yet.
                end
              rescue
                logger.warn "error #{result}"
              end
            end
          when "lg"
            if in_left_td
              result += switch_to_right
              in_left_td = false
            end
            result += "<td>"
            begin
              ls = node.children
              ls.each do |l|
                result += "<p>" + l.text.to_s.strip + "</p>"
              end
            rescue
              logger.warn "error #{result}"
            end
          when "head"
            unless result.nil?
              begin
                result += "<p></p>"
              rescue
                logger.warn "error #{result}"
              end
            end
          else
            if in_left_td
              result += switch_to_right
              in_left_td = false
            end
            logger.warn node.name.to_s
          end
          result += if in_left_td
                      "</td><td>&nbsp;</td>"
                    else
                      "</td>"
                    end
          in_left_td = true
          result += "</tr>"
        end
      end

      result += render_subject_terms(tei_xml, chapter)
      result += render_footnotes(footnotes)
      result += show_tei_table_end
      result
    end
    private_class_method :render_text_page

    def self.render_page_p(node, in_left_td)
      result = ""
      footnotes = ""
      children = node.children
      result += "<p>"
      children.each do |child|
        child_text = child.text.to_s.strip
        if child.name == "text" && !child_text.empty? && child.type == 3
          if in_left_td
            result += switch_to_right
            result += "<td>"
            in_left_td = false
          end
          result += child.text
        elsif child.name == "pb"
          unless in_left_td
            result += switch_to_left
            in_left_td = true
          end
          result += render_pb(child)
          in_left_td = true
        elsif child.name == "figure"
          unless in_left_td
            result += switch_to_left
            in_left_td = true
          end
          result += "<ul class=thumbnails><li>"
          pid = PidMethods.urn_to_f3_pid(child['n'])
          image = Image.where(legacy_pid_tesim: pid)
          image = image.first
          image_id = image.thumbnail_id unless image.nil?
          object_id = image.id unless image.nil?
          object_id = "unknown" if object_id.nil?
          image_id = "unknown" if image_id.nil?
          result += '<a data-pid="' + object_id + '" href="/concern/images/' + object_id + '"  class="thumbnail">'
          result += '<img src="/downloads/' + image_id + '?file=thumbnail">'
          result += "</a>"
          result += "</li></ul>"
        elsif child.name == "quote"
          if in_left_td
            result += switch_to_right
            result += "<td>"
            in_left_td = false
          end
          result += get_block_quote(child)
        elsif child.name == "table"
          if in_left_td
            result += switch_to_right
            result += "<td>"
            in_left_td = false
          end
          result += render_table(child, in_left_td)
        elsif child.name == "note"
          result_fn, result_foot = get_foot_note(child)
          result += result_fn unless result_fn.nil?
          footnotes += result_foot
        end
      end
      result += "</p>"
      [result, in_left_td, footnotes]
    end
    private_class_method :render_page_p

    def self.render_table(node, _in_left_td)
      result = "<table>"
      rows = node.children
      rows.each do |row|
        result += "<tr>"
        row.children.each do |col|
          result += "<td>"
          text = col.text.to_s.strip
          result += text.presence || "&nbsp;"
          result += "</td>"
        end
        result += "</tr>"
      end
      result += "</table>"
      result
    end
    private_class_method :render_table

    def self.render_footnotes(footnotes)
      result = ""
      if footnotes.present?
        result = "<tr><td>&nbsp;</td><td>"
        result += "<br/>"
        result += "<span class=maintextviewer-footnotesheader>Footnotes:</span><hr/>"
        result += footnotes
        result += "</td></tr>"
      end

      result
    end
    private_class_method :render_footnotes

    def self.render_subject_terms(tei_xml, chapter)
      result = '<tr><td>&nbsp;</td><td>'
      # at the end of the chapter/ look for subject terms list, print header.
      node_sets = tei_xml.xpath('//body/div1[@id="' + chapter + '"]/list/head|//body/div1/div2[@id="' + chapter + '"]/list/head')
      node_sets&.each do |node|
        result += "<h5 class=subject_terms>" + node + "</h5>"
      end

      # at the end of the chapter/ look for subject terms list, print actual list with subject searches.
      node_sets = tei_xml.xpath('//body/div1[@id="' + chapter + '"]/list/item|//body/div1/div2[@id="' + chapter + '"]/list/item')
      node_sets&.each do |node|
        result += "<div class=subject_list_item><a href='/catalog?f[subject_facet][]=" + node + "'>" + node + "</a></div>"
      end

      result += '</tr></td>'
      result
    end
    private_class_method :render_subject_terms

    def self.switch_to_right
      "</td>"
    end
    private_class_method :switch_to_right

    def self.switch_to_left
      "</td><tr><td class=pagenumber>"
    end
    private_class_method :switch_to_left
  end
end
