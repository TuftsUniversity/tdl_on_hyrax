# frozen_string_literal: true
require 'active_fedora'
require 'om'

namespace :tufts do
  def full_path(element)
    result = element.name

    while element.respond_to?(:parent)
      element = element.parent
      result = "#{element.name}/#{result}"
    end

    result
  end

  desc 'find <archref>, <extref> and/or <extptr> tags in eads'

  task find_ead_refs: :environment do
    if ARGV.size != 2
      puts('example usage: rake tufts:find_ead_refs some_ead_pids.txt')
    else
      filename = ARGV[1]

      File.readlines(filename).each do |line|
        id = line.strip
        msg = ''

        begin
          next if id.blank?

          document_fedora = ActiveFedora::Base.find(id)
          document_ead = Datastreams::Ead.from_xml(document_fedora.file_sets.first.original_file.content)
          document_ead = document_ead.ng_xml.remove_namespaces!

          archrefs = document_ead.xpath('//archref')
          extrefs = document_ead.xpath('//extref')
          extptrs = document_ead.xpath('//extptr')

          next if archrefs.empty? && extrefs.empty? && extptrs.empty?

          archrefs.each do |archref|
            path = full_path(archref)
            msg += "  #{archref}\n"
            msg += "    full path is #{path}\n"
            msg += "    NO TEXT!!!!!\n" if archref.text.blank?
            msg += "    NO HREF!!!!!\n" if archref.attribute('href').blank?
          end

          extrefs.each do |extref|
            path = full_path(extref)
            next if path == 'document/ead/eadheader/filedesc/publicationstmt/p/extref' && id != '5h73q6049' # Almost every EAD has one of these.
            msg += "  #{extref}\n"
            msg += "    full path is #{path}\n"
            msg += "    NO TEXT!!!!!\n" if extref.text.blank?
            msg += "    NO HREF!!!!!\n" if extref.attribute('href').blank?
          end

          extptrs.each do |extptr|
            path = full_path(extptr)
            next if path == 'document/ead/eadheader/filedesc/publicationstmt/address/addressline/extptr' && id != '5h73q6049' # Almost every EAD has one of these.
            msg += "  #{extptr}\n"
            msg += "    full path is #{path}\n"
            msg += "    NO TEXT!!!!!\n" if extptr.text.blank?
            msg += "    NO HREF!!!!!\n" if extptr.attribute('href').blank?
          end

        rescue ActiveFedora::ObjectNotFoundError
          # This work was not found.
          msg += "  not found\n"
        rescue StandardError => ex
          # Something went wrong.  For example, "ActiveFedora::RecordInvalid: Validation failed: Embargo release date Must be a future date".
          exception_msg = " " + ex.class.name + " " + ex.message
          msg += "  caused the exception " + exception_msg + "\n"
        end

        puts(id + "\n" + msg + "\n") if msg.present?
      end
    end
  end
end
