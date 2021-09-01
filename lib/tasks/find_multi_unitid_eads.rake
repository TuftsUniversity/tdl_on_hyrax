# frozen_string_literal: true
require 'active_fedora'
require 'om'

namespace :tufts do
  desc 'find eads that have multi-valued unitids'

  task find_multi_unitid_eads: :environment do
    if ARGV.size != 2
      puts('example usage: rake tufts:find_multi_unitid_eads some_ead_pids.txt')
    else
      found_count = 0
      not_found_array = []
      multi_unitid_array = []
      exception_array = []

      filename = ARGV[1]

      File.readlines(filename).each do |line|
        id = line.strip
        msg = ''

        begin
          next if id.blank?

          document_fedora = ActiveFedora::Base.find(id)
          document_ead = Datastreams::Ead.from_xml(document_fedora.file_sets.first.original_file.content)
          document_ead&.ng_xml&.remove_namespaces!
          unitid = document_ead.find_by_terms_and_value(:unitid)

          msg += unitid.text
          found_count += 1

          if unitid.children.length > 1
            multi_unitid_array << id + ': ' + msg
            msg += ' has multiple unitids'
          end

        rescue ActiveFedora::ObjectNotFoundError
          # This work was not found.
          not_found_array << id
          msg += 'not found'
        rescue StandardError => ex
          # Something went wrong.  For example, "ActiveFedora::RecordInvalid: Validation failed: Embargo release date Must be a future date".
          exception_msg = ' ' + ex.class.name + ' ' + ex.message
          exception_array << id + exception_msg
          msg += ' caused the exception' + exception_msg
          found_count += 1
        end

        puts(id + ': ' + msg)
      end

      # How many works were found?
      if found_count.positive?
        puts(found_count.to_s + (found_count == 1 ? ' work was' : ' works were') + ' found.')
      end

      # How many works were not found?
      not_found_count = not_found_array.size

      if not_found_count.positive?
        puts(not_found_count.to_s + (not_found_count == 1 ? ' work was' : ' works were') + ' not found:')

        not_found_array.each do |not_found_id|
          puts('  ' + not_found_id)
        end
      end

      # How many works caused exceptions?
      exception_count = exception_array.size

      if exception_count.positive?
        puts('  ' + exception_count.to_s + (exception_count == 1 ? ' work caused an exception' : ' works caused exceptions') + ':')

        exception_array.each do |exception_msg|
          puts('    ' + exception_msg)
        end
      end

      # How many works had multiple unitids?
      multi_unitid_count = multi_unitid_array.size

      if multi_unitid_count.positive?
        puts(multi_unitid_count.to_s + (multi_unitid_count == 1 ? ' work has' : ' works have') + ' multiple unitids:')

        multi_unitid_array.each do |multi_unitid_id|
          puts('  ' + multi_unitid_id)
        end
      end
    end
  end
end
