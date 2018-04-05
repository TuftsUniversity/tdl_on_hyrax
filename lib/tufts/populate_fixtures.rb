module Tufts
  class PopulateFixtures
    def self.singular_terms
      GenericObject
        .properties.select { |_, cf| cf.try(:multiple?) == false }
        .keys.map(&:to_sym)
    end

    SHARED_TERMS = [:title, :displays_in, :abstract, :accrual_policy, :admin_start_date,
                    :alternative_title, :audience, :bibliographic_citation,
                    :contributor, :corporate_name, :createdby, :creator, :creator_department, :date_accepted,
                    :date_available, :date_copyrighted, :date_issued, :date_modified, :date_uploaded,
                    :description, :embargo_note, :end_date, :extent, :format_label, :funder, :genre, :has_format, :has_part,
                    :held_by, :identifier, :internal_note, :is_format_of, :is_replaced_by, :language, :legacy_pid,
                    :personal_name, :primary_date, :provenance, :publisher, :qr_note, :qr_status,
                    :rejection_reason, :replaces, :resource_type, :retention_period, :rights_holder, :rights_note,
                    :geographic_name, :steward, :subject, :table_of_contents, :temporal, :is_part_of, :tufts_license, :source].freeze
    EARLY_TERMS = [:date_uploaded, :date_modified].freeze
    REMOVE_TERMS = [:keyword, :based_near, :location].freeze
    SINGULAR_TERMS = Tufts::PopulateFixtures.singular_terms - REMOVE_TERMS - EARLY_TERMS
    MULTI_TERMS = SHARED_TERMS - SINGULAR_TERMS - REMOVE_TERMS - EARLY_TERMS

    def initialize
      @seed_data = make_seed_data_hash
      @user = User.find_or_create_by!(email: 'fixtureloader@tufts.edu') do |user|
        user.password = SecureRandom.base64(24)
      end
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
      newid
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
      GC.start
      admin_set = AdminSet.find(AdminSet::DEFAULT_ID)
      case metadata[:model]
      when "image"
        # build core object
        object = Image.new(id: pid)
      when "votingRecord"
        object = VotingRecord.new(id: pid)
      when "ead"
        object = Ead.new(id: pid)
      when "rcr"
        object = Rcr.new(id: pid)
      else
        Rails.logger.warn "There is no support for #{metadata[model]} fixtures.  You'll have to add it."
      end

      object.admin_set = admin_set
      object.visibility = metadata[:visibility]
      object.apply_depositor_metadata @user.email
      object.date_uploaded = DateTime.current.to_date
      object.date_modified = DateTime.current.to_date

      # build fileset for object
      file_set = FileSet.new
      file_label = metadata[:file].sub('fixtures/', '')
      file_set.label = file_label
      file_set.apply_depositor_metadata @user.email
      file_set.title = Array(file_label)
      file_set.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      work_permissions = object.permissions.map(&:to_hash)

      # create actor to attach fileset to object
      actor = Hyrax::Actors::FileSetActor.new(file_set, @user)
      # actor.create_metadata("visibility" => Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC)
      # Ldp::Conflict
      tries = 3
      begin
        path = Rails.root.join('spec', metadata[:file])
        actor.create_content(File.open(path))
        Hyrax.config.callback.run(:after_import_local_file_success, file_set, @user, path)
        actor.attach_to_work(object)
        actor.file_set.permissions_attributes = work_permissions
        file_set.save!
      rescue Ldp::Conflict
        tries -= 1
        if tries > 0
          sleep(5.seconds)
          retry
        else
          Rails.logger.error "Fixture file missing original for #{file_set.id}"
        end
      end

      MULTI_TERMS.each do |term|
        val = Array(metadata[term])
        object.send("#{term}=", val) unless val.nil?
      end

      SINGULAR_TERMS.each do |term|
        val = metadata[term]
        object.send("#{term}=", val) unless val.nil?
      end

      # TODO: Download show download link to all users needs metadata
      # add to collection if it exists
      #      collection_title = metadata[:collection_title]
      #      unless collection_title.nil?
      #        collection = Collection.where(title: collection_title)
      #        object.member_of_collections = collection
      #      end

      object.save!

      # create dervivatives
      object.reload
      file_set.reload
      tries = 3
      begin
        CreateDerivativesJob.perform_now(file_set, file_set.public_send(:original_file).id)
      rescue NoMethodError
        tries -= 1
        if tries > 0
          sleep(5.seconds)
          retry
        else
          Rails.logger.error "Fixture file missing original for #{file_set.id}"
        end
      end
      # save and return object
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
        # https://github.com/TuftsUniversity/epigaea/blob/master/config/authorities/resource_types.yml
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
        model: "image",
        collection_title: "Fletcher School Records, 1923 -- 2016"
      },
      {
        title: "Illinois 1824 President of the United States",
        legacy_pid: "tufts:il.president.1824",
        identifier: "http://hdl.handle.net/10427/56366",
        creator: ["Philip Lampi", "Tufts University Digital Collections and Archives", "American Antiquarian Society"],
        description: "Illinois 1824 President of the United States. The permanent URL for this resource is: http://hdl.handle.net/10427/56366",
        publisher: "Tufts University. Digital Collections and Archives.",
        source: "MS115",
        primary_date: "1824",
        date_issued: "2015-05-26-04:00",
        resource_type: "http://purl.org/dc/dcmitype/Dataset",
        format_label: "text/xml",
        personal_name: ["John Quincy Adams", "Andrew Jackson", "Henry Clay", "William H. Crawford"],
        geographic_name: "Illinois",
        bibliographic_citation: 'American Antiquarian Society and Tufts University Digital Collections and Archives. "Illinois 1824 President of the United  States." 2010. Tufts University. Digital Collections and Archives. Medford, MA. http://hdl.handle.net/10427/56366',
        temporal: "1824",
        funder: "National Endowment for the Humanities",
        steward: "dca",
        displays_in: ["dl", "elections"],
        createdby: "NNV",
        visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC,
        rights_statement: "http://dca.tufts.edu/ua/access/rights-pd.html",
        file: 'fixtures/tufts_il.president.1824.xml',
        model: "votingRecord",
        collection_title: "Fletcher School Records, 1923 -- 2016"
      },
      {
        legacy_pid: "tufts:trove.23.200",
        title: "The Arch of Titus.",
        description: ["This triumphal arch commemorates Titus' victories, including the Siege of Jerusalem in 70 AD. The main inscription used to be ornamented by letters made of perhaps silver, gold or some other metal, and reads: \"The Roman Senate and People (dedicate this) to the divine Titus Vespasianus Augustus, son of the divine Vespasian.\"", "Location created: Rome.", "Date created: c. 81 CE.", "Medium: Concrete and white marble.", "Measurements: 15m tall.", "Original file name: 14.8493-6.36a"],
        publisher: "Tufts University. Tisch Library.",
        source: "Stokstad",
        primary_date: "0081",
        date_created: "2017-10-05T08:14:43.241-04:00",
        resource_type: "http://purl.org/dc/dcmitype/Image",
        format_label: "image/tiff",
        subject: ["Italy--antiquities.", "Architecture, Roman--Italy--Rome.", "Relief (Sculpture), Roman.", "Marble sculpture, Roman."],
        genre: ["triumphal arches (memorial arches)", "Early Imperial.", "reliefs (sculptures)", "marble (rock)"],
        rights_statement: "http://dca.tufts.edu/ua/access/rights-pd.html",
        temporal: "1st century.",
        steward: "tisch",
        createdby: "amay02",
        internal_note: "ArtBatchIngest: 2017-10-05T08:14:43.241-04:00; Tisch manages metadata and binary.",
        displays_in: ["trove"],
        visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED,
        file: 'fixtures/IMG_2077-a.jpg',
        model: "image"
      },
      {
        legacy_pid: "tufts:test.aspace.MS999",
        title: "Lorem Ipsum papers, 1897-1933",
        alternative_title: "Kitchen Sink EAD",
        creator: "Brian Goodmon",
        date_created: "2016",
        displays_in: ["dl"],
        visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC,
        rights_statement: "http://sites.tufts.edu/dca/about-us/research-help/reproductions-and-use/",
        file: 'fixtures/MS999.archival.xml',
        model: "ead"
      },
      {
        legacy_pid: "tufts:test.aspace.MS226",
        title: "ASpace Rubin Carter Papers",
        creator: "Brian Goodmon",
        date_created: "2016",
        displays_in: ["dl"],
        visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC,
        rights_statement: "http://sites.tufts.edu/dca/about-us/research-help/reproductions-and-use/",
        file: 'fixtures/MS226.archival.xml',
        model: "ead", format_label: "text/xml"

      },
      {
        legacy_pid: "tufts:RCR00579",
        identifier: ["RCR00579", "http://hdl.handle.net/10427/71593"],
        title: "Tisch Library",
        publisher: "Digital Collections and Archives, Tufts University",
        primary_date: "2010-02-09",
        date_issued: "2011-09-21",
        date_available: "2011-06-17",
        resource_type: "http://purl.org/dc/dcmitype/Text",
        format_label: "text/xml",
        rights_statement: "http://dca.tufts.edu/ua/access/rights-pd.html",
        visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC,
        steward: "dca",
        displays_in: ["dl"],
        createdby: "CIDER",
        file: 'fixtures/RCR00579.xml',
        model: "rcr"
      }
    ].freeze
  end
end
