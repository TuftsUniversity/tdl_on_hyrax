module Tufts
  class PopulateFixtures
    attr_reader :seed_data

    def initialize
      @seed_data = make_seed_data_hash
    end

    def make_seed_data_hash
      seed_hash = {}
      SEED_DATA.each do |c|
        id = convert_id(c[:legacy_pid])
        seed_hash[id] = c
      end
      seed_hash
    end

    # Convert a legacy Tufts identifier into a predictable and valid Fedora identifier
    # @param [String] id
    # @return [String]
    def convert_id(id)
      newid = id.downcase
      newid.slice!('tufts:')
      newid.tr!('.', '_')
    end

    def self.eradicate_fixtures
      Tufts::PopulateFixtures.new.eradicate_fixtures
    end

    def eradicate_fixtures
      @seed_data.each_key do |pid|
        find_and_eradicate_object(pid, @seed_data[pid])
      end
    end

    def self.create_fixtures
      Tufts::PopulateFixtures.new.create_fixtures
    end

    def create_fixtures
      @seed_data.each_key do |pid|
        find_or_create_object(pid, @seed_data[pid])
      end
    end

    def find_and_eradicate_object(pid, _metadata)
      work = ActiveFedora::Base.find(pid)
      work.delete
      ActiveFedora::Base.eradicate(pid)
    rescue ActiveFedora::ObjectNotFoundError
      # no-op
    rescue Ldp::Gone
      # no-op
    end

    def find_or_create_object(pid, metadata)
      ActiveFedora::Base.find(pid)
    rescue ActiveFedora::ObjectNotFoundError
      create_object(pid, metadata)
    rescue Ldp::Gone
      ActiveFedora::Base.eradicate(pid)
      create_object(pid, metadata)
    end

    # @param [String] pid
    # @return [ActiveFedora::Base]
    def create_object(pid, metadata)
      admin_set = AdminSet.find(AdminSet::DEFAULT_ID)
      case metadata[:model]
      when "image"
        object = Image.new(id: pid)
        object.admin_set = admin_set
        object.visibility = metadata[:visibility]
        object.apply_depositor_metadata 'fixtureloader'
        object.date_uploaded = DateTime.current.to_date
        object.date_modified = DateTime.current.to_date
        file_set = FileSet.new
        file_set.label = metadata[:file]
        file_set.apply_depositor_metadata 'fixtureloader'
        file_set.title = Array(metadata[:file])
        file_set.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
        user = User.find(1)
        actor = Hyrax::Actors::FileSetActor.new(file_set, user)
        actor.create_metadata("visibility" => Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC)
        path = Rails.root.join('spec', metadata[:file])
        actor.create_content(File.open(path))
        Hyrax.config.callback.run(:after_import_local_file_success, file_set, user, path)
        actor.attach_to_work(object)
        work_permissions = object.permissions.map(&:to_hash)
        actor.file_set.permissions_attributes = work_permissions
        file_set.save
        # #IngestLocalFileJob.perform_later(file_set, path)

      else
        logger.warn "There is no support for #{metadata[model]} fixtures.  You'll have to add it."
      end

      # set metadata
      object.title = Array(metadata[:title])
      object.identifier = Array(metadata[:identifier])
      object.legacy_pid = metadata[:legacy_pid]
      object.creator = Array(metadata[:creator])
      object.description = Array(metadata[:description])
      object.publisher = Array(metadata[:publisher])
      object.source = Array(metadata[:source])
      object.primary_date = Array(metadata[:primary_date])
      object.date_issued = Array(metadata[:date_issued])
      object.date_available = Array(metadata[:date_available])
      object.format_label = Array(metadata[:format_label])
      object.extent = Array(metadata[:extent])
      object.personal_name = Array(metadata[:personal_name])
      object.subject = Array(metadata[:subject])
      object.temporal = Array(metadata[:temporal])
      object.steward = metadata[:steward]
      object.displays_in = Array(metadata[:displays_in])
      object.createdby = Array(metadata[:createdby])
      object.resource_type = Array(metadata[:resource_type])
      object.rights_statement = Array(metadata[:rights_statement])
      # Download show download link to all users

      # save and return object
      object.save!
      object.reload
      file_set.reload
      CreateDerivativesJob.perform_now(file_set, file_set.public_send(:original_file).id)
      # object = Image.find(pid)
      # #asset_path = object.file_sets[0].original_file.uri.to_s
      # sset_path = asset_path[asset_path.index(object.file_sets[0].id.to_s)..-1]
      # CreateDerivativesJob.perform_now(object.file_sets[0], asset_path)

      object
    end

    SEED_DATA = [
      {
        title: "Story of Jumbo book cover",
        legacy_pid: "tufts:MS002.001.015.00001.00001",
        identifier: "http://hdl.handle.net/10427/35371",
        creator: "Edwards, W.F.L.",
        description: '9 1/4 x 7. This book cover illustration is from W.F.L. Edwards, "The Story of Jumbo" (St. Thomas [Ont.] : Sutherland Press, c.1935).',
        publisher: "Digital Collections and Archives, Tufts University",
        source: "MS002",
        primary_date: "1935",
        date_issued: "2010-09-29",
        date_available: "20070821",
        resource_type: "http://purl.org/dc/dcmitype/Image",
        format_label: "image/tiff",
        extent: "68653328 bytes",
        personal_name: "Jumbo",
        subject: ["Elephants", "Forests", "Books"],
        rights_statement: "http://sites.tufts.edu/dca/about-us/research-help/reproductions-and-use/",
        temporal: "1935",
        # Is member of collection tufts:UA069.006.DO.MS002
        steward: "dca",
        displays_in: ["dl"],
        createdby: "CIDER",
        visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC,
        # Download show download link to all users
        file: 'fixtures/MS002.001.015.00001.00001.basic.jpg',
        model: "image"
      }

    ].freeze
  end
end
