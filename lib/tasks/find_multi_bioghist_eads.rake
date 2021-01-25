require 'active_fedora'
require 'om'

namespace :tufts do
  desc 'find eads that have multiple bioghist elements'

  task find_multi_bioghist_eads: :environment do
    if ARGV.size != 2
      puts('example usage: rake tufts:find_multi_bioghist_eads some_ead_pids.txt')
    else
      found_count = 0
      not_found_array = []
      multi_bioghist_array = []
      exception_array = []

      filename = ARGV[1]

      File.readlines(filename).each do |line|
        id = line.strip
        msg = ''

        begin
          next unless id.present?

          document_fedora = ActiveFedora::Base.find(id)
          document_ead = Datastreams::Ead.from_xml(document_fedora.file_sets.first.original_file.content)
          document_ead.ng_xml.remove_namespaces! unless document_ead.nil?
          bioghisths = document_ead.find_by_terms_and_value(:bioghisth)

          unless bioghisths.nil?
            found_count += 1

            unless bioghisths.length == 1
              heads = ''

              bioghisths.each_with_index do |bioghisth, index|
                heads += (index == 0 ? '' : ', ') + bioghisth.text
              end

              multi_bioghist_array << id + ': ' + heads
              msg = 'has multiple bioghists (' + heads + ')'
            end
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

      puts

      # How many works were found?
      if found_count > 0
        puts(found_count.to_s + (found_count == 1 ? ' work was' : ' works were') + ' found.')
      end

      # How many works were not found?
      not_found_count = not_found_array.size

      if not_found_count > 0
        puts(not_found_count.to_s + (not_found_count == 1 ? ' work was' : ' works were') + ' not found:')

        not_found_array.each do |not_found_id|
          puts('  ' + not_found_id)
        end
      end

      # How many works caused exceptions?
      exception_count = exception_array.size

      if exception_count > 0
        puts('  ' + exception_count.to_s + (exception_count == 1 ? ' work caused an exception' : ' works caused exceptions') + ':')

        exception_array.each do |exception_msg|
          puts('    ' + exception_msg)
        end
      end

      # How many works had multiple bioghists?
      multi_bioghist_count = multi_bioghist_array.size

      if multi_bioghist_count > 0
        puts(multi_bioghist_count.to_s + (multi_bioghist_count == 1 ? ' work has' : ' works have') + ' multiple bioghists:')

        multi_bioghist_array.each do |multi_bioghist_id|
          puts('  ' + multi_bioghist_id)
        end
      end
    end
  end
end
