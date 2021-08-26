# frozen_string_literal: true
require 'active_fedora'
require 'om'

namespace :tufts do
  desc 'find the indexable fields in an ead, ie the interesting tags under controlaccess'

  task find_ead_indexable_fields: :environment do
    if ARGV.size != 2
      puts('example usage: rake tufts:find_ead_indexable_fields some_ead_pids.txt')
    else
      filename = ARGV[1]

      File.readlines(filename).each do |line|
        id = line.strip
        msg = ''

        begin
          next if id.blank?
          puts(id)
          results = {}

          EadsHelper.find_indexable_fields(id, results)

          results.each do |field_name, field_values|
            puts("  #{field_name}")

            field_values.each do |field_value|
              puts("    #{field_value}")
            end
          end

        rescue ActiveFedora::ObjectNotFoundError
          # This work was not found.
          msg += 'not found'
        rescue StandardError => ex
          # Something went wrong.  For example, "ActiveFedora::RecordInvalid: Validation failed: Embargo release date Must be a future date".
          exception_msg = ' ' + ex.class.name + ' ' + ex.message
          msg += 'caused the exception' + exception_msg
        end

        puts("  " + msg) if msg.present?
      end
    end
  end
end
