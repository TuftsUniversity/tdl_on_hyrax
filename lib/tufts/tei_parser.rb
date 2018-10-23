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
      if chapter == "title" || (chapter.start_with? "front")
        return show_tei_cover(fedora_obj, tei, chapter)
      end

      # special case show the back cover
      if chapter.starts_with? "back"
        return show_tei_backpage(fedora_obj, tei, chapter)
      end
      show_tei_page(fedora_obj, tei, chapter)
    end

    private

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
          if !node.nil? && node['type'] == 'frontispiece'
            node = node_sets.to_ary[1]
          end
          result << ctext(node)
        else
          unless node_sets.nil?
            node_sets.each do |node|
              if chapter == 'title' || (chapter != "title" && chapter == node['id'])
                result << ctext(node)
              end
            end
          end
        end

        result += show_tei_table_end

        result
      end
      ####################
      # TEI Back Page
      ####################

      def self.show_tei_backpage(_fedora_obj, tei, chapter)
        result = ""
        result += show_tei_table_start

        node_sets = tei.xpath('/TEI.2/text/back/div1')
        unless node_sets.nil?
          node_sets.each do |node|
            if chapter == 'title' || (chapter != "title" && chapter == node['id'])
              result << ctext(node)
            end
          end
        end

        result += show_tei_table_end
        result
      end

      ####################
      # TEI Tables
      ####################
      def self.show_tei_table_start
        '<table cellpadding="2" cellspacing="5" class="noborder bookviewer_table"><tbody>'
        end

      def self.show_tei_table_end
        '</tbody></table>'
      end

      # recursive function to walk the title page stick everything into divs
      def self.ctext(el)
        return "" if el.nil?
        return el.text if el.text?
        result = []
        for sel in el.children
          if sel.element?
            type = sel[:type]
            if sel.name == 'figure'
              pid = PidMethods.urn_to_f3_pid(sel['n'])
              result.push("<br/><br/><img alt=\"\" src=\"" + "/file_assets/" + pid + "\"></img>")
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

      def self.show_tei_page(fedora_obj, tei, chapter)
    # render the requested chapter.
    # NOTE: should break this out into a method probably.
    result = ""
    footnotes =""
    node_sets = tei.xpath('//body/div1[@id="' + chapter +'"]/head|//body/div1/div2[@id="' + chapter +'"]/head')
    unless node_sets.nil?
      node_sets.each do |node|
        result += "<h6>" + node + "</h6><br/>"

      end
    end


    # render the bibl
    node_sets = tei.xpath('//body/div1[@id="' + chapter +'"]/head|//body/div1/div2[@id="' + chapter +'"]/bibl')
    unless node_sets.nil?
      node_sets.each do |node|
        result += "<p class=" + node.name + ">" + node + "</p>"

      end
    end

    #peek ahead and see if this is an image book if not render it as a standard text book.
    #result +="<p> is chapter image book : "+ (is_chapter_image_book(fedora_obj, chapter).to_s) +"</p>"
    if is_chapter_image_book(fedora_obj, tei, chapter)
      result += render_image_page(fedora_obj, chapter)
    else
      result += render_text_page(tei, chapter, footnotes)
    end

    return result
  end

  def self.is_chapter_image_book(fedora_obj, tei, chapter)
      node_sets = tei.xpath('//body/div1[@id="'+chapter+'"]/figure|//body/div1[@id="' + chapter +'"]/p|//body/div1/div2[@id="' + chapter +'"]/p|//body/div1[@id="' + chapter +'"]/quote|//body/div1/div2[@id="' + chapter +'"]/quote')
      unless node_sets.nil?
        node_sets.each do |node|
          if node.parent['rend'] == 'page-image'
            return true
          else
            return false
          end
        end
      end
      return false
    end

    def self.render_text_page(tei_xml, chapter, footnotes)
        result = self.show_tei_table_start
        node_sets = tei_xml.xpath('//body/div1[@id="' + chapter +'"]/p|//body/div1/div2[@id="' + chapter +'"]/p|//body/div1[@id="' + chapter +'"]/quote|//body/div1/div2[@id="' + chapter +'"]/quote|//body/div1/div2[@id="' + chapter + '"]|//body/div1[@id="' + chapter + '"]')
        in_left_td = true
        unless node_sets.nil?
          if node_sets.first.name == "div1"
            node_sets = node_sets.first.children
          end
          node_sets.each do |node|
            node_text = node.text.to_s.strip
            unless node_text.nil? || node_text.empty?
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
                  #if we're in the left close it.
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
                    result += self.ctext(node)
                  else
                    begin
                      ls = node.children
                      ls.each do |l|
                        #result += "<p>" + l.text.to_s.strip + "</p>"
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
                      puts "error #{result}"
                    end
                  end
                else
                  if in_left_td
                    result += switch_to_right
                    in_left_td = false
                  end
                  logger.warn "#{node.name}"
              end
              if in_left_td
                result +="</td><td>&nbsp;</td>"
                in_left_td = true
              else
                result += "</td>"
                in_left_td=true
              end
              result += "</tr>"
            end
          end
        end

        result += render_subject_terms(tei_xml, chapter)
        result += render_footnotes(footnotes)
        result += self.show_tei_table_end
        result
      end
      def self.render_page_p(node, in_left_td)
          result = ""
          footnotes =""
          children = node.children
          result +="<p>"
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
              result +="<ul class=thumbnails><li>"
              pid = PidMethods.urn_to_f3_pid(child['n'])
              result +='<a data-pid="'+ pid+'" href="/catalog/' + pid + '"  class="thumbnail">'
              result +='<img src="http://dl.tufts.edu/file_assets/thumb/' + pid + '">'
              result +="</a>"
              result +="</li></ul>"
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
              unless result_fn.nil?
                result += result_fn
              end
              footnotes += result_foot
            end

          end
          result +="</p>"


          return result, in_left_td, footnotes
        end


            def self.render_footnotes(footnotes)
              result =""
              unless footnotes.nil? || footnotes.empty?
                result = "<tr><td>&nbsp;</td><td>"
                result += "<br/>"
                result += "<span class=maintextviewer-footnotesheader>Footnotes:</span><hr/>"
                result += footnotes
                result += "</td></tr>"
              end

              result
            end

        def self.render_subject_terms(tei_xml, chapter)
            result = '<tr><td>&nbsp;</td><td>'
            # at the end of the chapter/ look for subject terms list, print header.
            node_sets = tei_xml.xpath('//body/div1[@id="' + chapter +'"]/list/head|//body/div1/div2[@id="' + chapter +'"]/list/head')

            unless node_sets.nil?
              node_sets.each do |node|
                result += "<h5 class=subject_terms>" + node + "</h5>"

              end
            end

            # at the end of the chapter/ look for subject terms list, print actual list with subject searches.
            node_sets = tei_xml.xpath('//body/div1[@id="' + chapter +'"]/list/item|//body/div1/div2[@id="' + chapter +'"]/list/item')

            unless node_sets.nil?
              node_sets.each do |node|

                result += "<div class=subject_list_item><a href='/catalog?f[subject_facet][]="+ node+"'>" + node + "</a></div>"

              end
            end

            result += '</tr></td>'
            result
          end
      def self.switch_to_right
          return "</td>"
        end

        def self.switch_to_left
          return "</td><tr><td class=pagenumber>"
        end
  end
end
