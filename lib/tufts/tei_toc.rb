# frozen_string_literal: false

module Tufts
  module TeiToc
    include Tufts::TeiConstants
    ####################
    # Table of Contents
    ####################
    def get_toc(nokogiri_doc, pid)
      chapter_list = []
      toc_result = ""
      xml = nokogiri_doc
      node_sets = xml.xpath('/TEI.2/text/front/div1|/TEI.2/text/front/titlePage')
      node_sets&.each do |node|
        title = "Title Page"
        if node['n'].nil?
          type = node['type']
          unless type.nil?
            if type == 'preface'
              title = "Preface"
            elsif type == 'dedication'
              title = 'Dedication'
            elsif type == 'frontispiece'
              title = 'Frontispiece'
            end
          end
        else
          title = node['n']
        end

        toc_result +=
          TOC_PREDICATE +
          "<a class='collapse_tei_td' href='/teiviewer/" \
          'parent' \
          '/' +
          pid +
          "/chapter/" +
          (node['id'].nil? ? "title" : node['id']) +
          "'>" +
          title +
          "</a><br/>" +
          TOC_SUFFIX

        chapter_list << (node['id'].nil? ? 'title' : node['id'])
      end

      node_sets = xml.xpath('/TEI.2/text/body/div1')

      node_sets&.each do |node|
        if node['type'].to_s == 'section' || node['type'].to_s == "part" || !xml.xpath("//TEI.2/text/body/div1[@id='" + node['id'].to_s + "']/div2").to_s.empty?
          toc_result += TOC_COLLAPSE_PREDICATE + "<a class='collapse_tei_td' href='/teiviewer/" + 'parent' + '/' + pid + "/chapter/" + node['id'].to_s + "'>" + node['n'].to_s + "</a>"
          toc_result += "<div class='collapse_content'>"
          toc_result2, chapter_list = get_subsection(pid, node, chapter_list)
          toc_result += toc_result2
          toc_result += "</div>"
          toc_result += TOC_SUFFIX
        else
          toc_result += TOC_PREDICATE + "<a href='/teiviewer/" + 'parent' + '/' + pid + "/chapter/" + node['id'].to_s + "'>" + node['n'].to_s + "</a>" + TOC_SUFFIX
          chapter_list << node['id'].to_s
        end
        #  result << ctext(node)
      end

      node_sets = xml.xpath('/TEI.2/text/back/div1')

      node_sets&.each do |node|
        toc_result += TOC_PREDICATE + "<a href='/teiviewer/" + 'parent' + '/' + pid + "/chapter/" + node['id'].to_s + "'>" + node['n'].to_s + "</a>" + TOC_SUFFIX
        # title = "Back Page"
        # title = node['n'] unless node['n'].nil?
        # toc_result += TOC_PREDICATE + "<a href='/teiviewer/" + pid + '/' + "fileset" + "/chapter/" + (node['id'].nil? ? "title" : node['id']) + "'>" + title + "</a>" + TOC_SUFFIX
        chapter_list << node['id']
      end

      [toc_result, chapter_list]
    end

    def get_subsection(pid, node, chapter_list)
      result = ""
      id = node['id']
      if id.nil?
        n = node['n']
        node_sets = node.xpath('/TEI.2/text/body/div1[@n="' + n + '"]/div2')
      else
        node_sets = node.xpath('/TEI.2/text/body/div1[@id="' + id + '"]/div2')
      end
      unless node_sets&.nil?
        node_sets.each do |node2|
          chapter_title = node2['n'].to_s
          chapter_title.nil? ? chapter_title = '[chapter]' : chapter_title
          if node2['id'].nil?
            result << "<a href='/teiviewer/" + 'parent' + '/' + pid + "/chapter/" + node['id'].to_s + "'>" + chapter_title + "</a><br/>"
            chapter_list << node['id'].to_s
          else
            result << "<a href='/teiviewer/" + 'parent' + '/' + pid + "/chapter/" + node2['id'].to_s + "'>" + chapter_title + "</a><br/>"
            chapter_list << node2['id'].to_s
          end
        end
      end
      [result, chapter_list]
    end
  end
end
