# frozen_string_literal: true
class CatalogController < ApplicationController
  include BlacklightRangeLimit::ControllerOverride
  include BlacklightAdvancedSearch::Controller
  include Hydra::Catalog
  include Hydra::Controller::ControllerBehavior
  include BlacklightOaiProvider::Controller

  # This filter applies the hydra access controls
  before_action :enforce_show_permissions, only: :show

  def self.uploaded_field
    solr_name('system_create', :stored_sortable, type: :date)
  end

  def self.modified_field
    solr_name('system_modified', :stored_sortable, type: :date)
  end

  configure_blacklight do |config|
    # default advanced config values
    config.http_method = :post
    config.advanced_search ||= Blacklight::OpenStructWithHashAccess.new
    config.advanced_search[:url_key] ||= 'advanced'
    config.advanced_search[:query_parser] ||= 'edismax'
    config.advanced_search[:form_solr_parameters] ||= {
      "facet.field" => [
        solr_name('human_readable_type', :facetable),
        solr_name('subject', :facetable),
        solr_name('dl_member_of_collections', :symbol)
      ],
      "facet.limit" => 5
    }

    config.view.gallery.partials = [:index_header, :index]
    config.view.masonry.partials = [:index]
    config.view.slideshow.partials = [:index]

    config.show.tile_source_field = :content_metadata_image_iiif_info_ssm
    config.show.partials.insert(1, :openseadragon)
    config.search_builder_class = ::SearchBuilder

    # Show gallery view
    config.view.gallery.partials = [:index_header, :index]
    config.view.slideshow.partials = [:index]

    # # Default parameters to send to solr for all search-like requests. See also SolrHelper# solr_search_params
    config.default_solr_params = if Rails.env.test?
                                   {
                                     qt: 'search',
                                     rows: 10,
                                     qf: 'title_tesim description_tesim creator_tesim keyword_tesim'
                                   }
                                 elsif Rails.env.stage?
                                   {
                                     qt: 'search',
                                     rows: 10,
                                     fq: 'workflow_state_name_ssim:published OR has_model_ssim:Collection',
                                     qf: 'title_tesim description_tesim creator_tesim keyword_tesim'
                                   }
                                 else
                                   {
                                     qt: 'search',
                                     rows: 10,
                                     fq: 'workflow_state_name_ssim:published',
                                     qf: 'title_tesim description_tesim creator_tesim keyword_tesim'
                                   }
                                 end

    # solr field configuration for document/show views
    config.index.title_field = solr_name('title', :stored_searchable)
    config.index.display_type_field = solr_name('has_model', :symbol)
    config.index.thumbnail_field = 'thumbnail_path_ss'

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    # config.add_facet_field solr_name('human_readable_type', :facetable), label: 'Type'
    config.add_facet_field solr_name('object_type', :facetable), label: 'Format'
    # config.add_facet_field solr_name('subject', :facetable), limit: 5
    config.add_facet_field solr_name('names', :facetable), limit: 5, label: 'Names'
    config.add_facet_field 'pub_date_facet_isim', label: 'Year', range: true
    config.add_facet_field solr_name('subject_topic', :facetable), limit: 5, label: 'Subject'
    config.add_facet_field solr_name('dl_member_of_collections', :symbol), limit: 5, label: 'Collections'
    config.add_facet_field solr_name('file_set_complex_types', :facetable), limit: 5, label: 'File Type'
    config.add_facet_field solr_name('creator_department', :facetable), limit: 10, label: 'Department'
    # The generic_type isn't displayed on the facet list
    # It's used to give a label to the filter that comes from the user profile
    config.add_facet_field solr_name('generic_type', :facetable), if: false

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field(
      solr_name('creator', :stored_searchable),
      itemprop: 'creator',
      link_to_search: solr_name('creator', :facetable)
    )
    config.add_index_field(
      solr_name('contributor', :stored_searchable),
      itemprop: 'contributor',
      link_to_search: solr_name('contributor', :facetable),
      if: :no_creator?
    )
    config.add_index_field(
      solr_name('primary_date', :stored_searchable),
      label: 'Date',
      itemprop: 'primaryDate'
    )
    config.add_index_field(
      solr_name('temporal', :stored_searchable),
      label: 'Date',
      itemprop: 'temporal',
      if: :no_primary_date?
    )
    config.add_index_field(
      solr_name('dl_member_of_collections', :symbol),
      label: 'Collection',
      link_to_search: solr_name('dl_member_of_collections', :symbol)
    )

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    config.add_show_field solr_name('title', :stored_searchable)
    config.add_show_field solr_name('temporal', :stored_searchable)
    config.add_show_field solr_name('description', :stored_searchable)
    config.add_show_field solr_name('keyword', :stored_searchable)
    config.add_show_field solr_name('subject', :stored_searchable)
    # TODO: Clean up config.add_show_field solr_name('subject', :stored_searchable), link_to_search: true
    config.add_show_field solr_name('genre', :stored_searchable)
    config.add_show_field solr_name('creator', :stored_searchable)
    config.add_show_field solr_name('contributor', :stored_searchable)
    config.add_show_field solr_name('publisher', :stored_searchable)
    config.add_show_field solr_name('based_near_label', :stored_searchable)
    config.add_show_field solr_name('language', :stored_searchable)
    config.add_show_field solr_name('date_uploaded', :stored_searchable)
    config.add_show_field solr_name('date_modified', :stored_searchable)
    config.add_show_field solr_name('date_created', :stored_searchable)
    config.add_show_field solr_name('license', :stored_searchable)
    config.add_show_field solr_name('format', :stored_searchable)
    config.add_show_field solr_name('identifier', :stored_searchable)

    # 'fielded' search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.
    #
    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.
    config.add_search_field('all_fields', label: 'All Fields') do |field|
      all_names = config.show_fields.values.map(&:field).join(" ")
      title_name = solr_name("title", :stored_searchable)
      field.solr_parameters = {
        qf: %( #{all_names} id all_text_timv title_tesim description_tesim creator_tesim
        keyword_tesim abstract_tesim accrual_policy_tesim
        alternative_title_tesim audience_tesim contributor_tesim
        corporate_name_tesim created_by_tesim creator_dept_tesim
        primary_date_tesim date_accepted_tesim date_available_tesim
        date_copyrighted_tesim date_created_tesim date_issued_tesim
        date_modified_tesim date_uploaded_tesim description_tesim
        displays_in_tesim ead_tesim embargo_note_tesim end_date_tesim extent_tesim
        format_label_tesim funder_tesim genre_tesim geographic_name_tesim
        has_part_tesim internal_note_tesim
        is_part_of_tesim is_replaced_by_tesim language_tesim
        tufts_license_tesim license_tesim held_by_tesim identifier_tesim
        personal_name_tesim provenance_tesim publisher_tesim qr_note_tesim
        qr_status_tesim created_by_tesim rejection_reason_tesim replaces_tesim
        retention_period_tesim rights_statement_tesim rights_holder_tesim
        rights_note_tesim source_tesim spatial_tesim admin_start_date_tesim
        steward_tesim subject_tesim table_of_contents_tesim temporal_tesim
        legacy_pid_tesim resource_type_tesim tufts_is_part_of_tesim
        file_set_date_created_simplified_tesim file_set_format_tesim
        pub_date_facet_isim creator_department_tesim),
        pf: title_name.to_s
      }
    end

    ##
    # Adds a search field. Saves some lines. Can optionally pass a block for more customization.
    # @param {str} name
    #   The name of the field, to be displayed and indexed as.
    # @param {BlacklightConfiguration} config
    #   The blacklight_config that we're adding the search fields to.
    def self.add_search_field(name, config)
      config.add_search_field(name) do |field|
        solr_name = solr_name(name, :stored_searchable)

        # :solr_local_parameters will be sent using Solr LocalParams
        # syntax, as eg {! qf=$title_qf }. This is neccesary to use
        # Solr parameter de-referencing like $title_qf.
        # See: http://wiki.apache.org/solr/LocalParams
        field.solr_local_parameters = {
          qf: solr_name,
          pf: solr_name,
          type: 'lucene',
          df: solr_name,
          'q.op': 'AND'
        }

        yield(field) if block_given?
        field
      end
    end

    ##
    # An extension of add_search_field that hides the field from basic search.
    # @param {str} name
    #   The name of the field, to be displayed and indexed as.
    # @param {BlacklightConfiguration} config
    #   The blacklight_config that we're adding the search fields to.
    def self.add_advanced_search_field(name, config)
      add_search_field(name, config) do |field|
        field.include_in_simple_select = false
        field.solr_local_parameters.delete(:pf)
      end
    end

    add_search_field('title', config)
    add_search_field('creator', config)
    add_search_field('description', config)
    config.add_search_field('thesis_type') do |field|
      solr_name = solr_name('dissertation_type', :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end
    add_advanced_search_field('abstract', config)
    add_advanced_search_field('bibliographic_citation', config)
    add_search_field('contributor', config)
    add_advanced_search_field('corporate_name', config)
    add_advanced_search_field('creator_department', config)
    add_search_field('aggregate_date', config) { |f| f.label = "Date" }
    config.add_search_field('date_created') do |field|
      solr_name = solr_name('created', :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end
    add_advanced_search_field('genre', config)
    add_search_field('keyword', config)
    add_search_field('language', config)
    config.add_search_field('geog_name') do |field|
      field.label = 'Geographic Name'
      solr_name = solr_name('geog_name', :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('persname') do |field|
      field.label = 'Personal Name'
      field.include_in_advanced_search = false
      solr_name = solr_name('persname', :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name,
        type: 'lucene',
        df: solr_name,
        'q.op': 'AND'
      }
    end

    config.add_search_field('family_name') do |field|
      field.label = 'Family Name'
      field.include_in_advanced_search = false
      solr_name = solr_name('famname', :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name,
        type: 'lucene',
        df: solr_name,
        'q.op': 'AND'
      }
    end

    config.add_search_field('geographic_name') do |field|
      field.label = 'Geographic Name'
      field.include_in_advanced_search = false
      solr_name = solr_name('geogname', :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name,
        type: 'lucene',
        df: solr_name,
        'q.op': 'AND'
      }
    end

    config.add_search_field('corpname') do |field|
      field.label = 'Corporate Name'
      field.include_in_advanced_search = false
      solr_name = solr_name('corpname', :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name,
        type: 'lucene',
        df: solr_name,
        'q.op': 'AND'
      }
    end

    add_advanced_search_field('personal_name', config)
    add_search_field('publisher', config)
    add_search_field('subject', config)
    add_advanced_search_field('temporal', config)
    add_search_field('source', config) { |f| f.include_in_advanced_search = false }
    add_search_field('resource_type', config) { |f| f.include_in_advanced_search = false }
    add_search_field('identifier', config) { |f| f.include_in_advanced_search = false }
    add_search_field('rights_statement', config) { |f| f.include_in_advanced_search = false }
    add_search_field('license', config) { |f| f.include_in_advanced_search = false }
    config.add_search_field('depositor') do |field|
      solr_name = solr_name('depositor', :symbol)
      field.include_in_advanced_search = false
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    # 'sort results by' select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    # label is key, solr field is value
    config.add_sort_field "score desc, pub_date_sortable_isi desc, title_si asc", label: 'relevance'
    config.add_sort_field 'pub_date_sortable_isi desc, title_si asc', label: "date \u25BC"
    config.add_sort_field 'pub_date_sortable_isi asc, title_si asc', label: "date \u25B2"
    config.add_sort_field 'author_si desc, title_si asc', label: "creator \u25BC"
    config.add_sort_field 'author_si asc, title_si asc', label: "creator \u25B2"
    config.add_sort_field 'title_si desc, pub_date_sortable_isi desc', label: "title \u25BC"
    config.add_sort_field 'title_si asc, pub_date_sortable_isi asc', label: "title \u25B2"

    # If there are more than this many search results, no spelling ('did you
    # mean') suggestion is offered.
    config.spell_max = 5

    # OAI-PMH Settings
    config.oai = {
      provider: {
        record_prefix: 'oai:tufts'
      }
    }
  end

  # disable the bookmark control from displaying in gallery view
  # Hyrax doesn't show any of the default controls on the list view, so
  # this method is not called in that context.
  def render_bookmarks_control?
    false
  end

  def show_thumb_from_id
    id = params[:id]
    item = ActiveFedora::Base.find(id)
    is_inactive = if item.state.nil?
                    false
                  else
                    item.state.fetch.rdf_label[0].to_s == "inactive" ? true : false
                  end
    raise ActiveRecord::RecordNotFound if is_inactive
    fs_id = item.representative.id
    redirect_to "https://dl.tufts.edu/downloads/#{fs_id}?file=thumbnail"
  end

  def legacy_file_assets
    id = params[:id]
    items = ActiveFedora::Base.where(legacy_pid_tesim: id)
    item = items.first unless items.empty?

    raise ActionController::RoutingError, 'Not Found' if item.nil?

    link = view_context.get_link_to_primary_binary(item)

    raise ActionController::RoutingError, 'Not Found' if link == ""

    redirect_to link
  end

  # rubocop:disable Metrics/MethodLength
  def show_legacy
    id = params[:id]
    if id.starts_with?('oai:tufts:')
      f4id = id.gsub('oai:tufts:', '')
      begin
        item = ActiveFedora::Base.find(f4id, cast: true)
      rescue
        raise ActionController::RoutingError, 'Not Found' if item.nil?
      end
    else
      items = ActiveFedora::Base.where(legacy_pid_tesim: id)
      item = items.first unless items.empty?

      raise ActionController::RoutingError, 'Not Found' if item.nil?

      f4id = item.id
    end

    model = item.class.to_s.pluralize.underscore
    redirect_to "https://dl.tufts.edu/concern/#{model}/#{f4id}"
  end

  def welcome
    index
  end

  ##
  # For use in index fields. Checks if creator is in the solr doc.
  #
  # @param {hash} document
  #   The solr document.
  #
  # @return {bool}
  #   If creator is in the doc or not.
  def no_creator?(_, document)
    document._source['creator_tesim'].nil?
  end

  ##
  # For use in index fields. Checks if primary_date is in the solr doc.
  #
  # @param {hash} document
  #   The solr document.
  #
  # @return {bool}
  #   If primary_date is in the doc or not.
  def no_primary_date?(_, document)
    document._source['primary_date_tesim'].nil?
  end
end
