# frozen_string_literal: true
module Hyrax
  # Creates the presenters of the members (member works and file sets) of a specific object
  class MemberPresenterFactory
    class_attribute :file_presenter_class, :work_presenter_class
    # modify this attribute to use an alternate presenter class for the files
    self.file_presenter_class = FileSetPresenter

    # modify this attribute to use an alternate presenter class for the child works
    self.work_presenter_class = WorkShowPresenter

    def initialize(work, ability, request = nil)
      @work = work
      @current_ability = ability
      @request = request
    end

    delegate :id, to: :@work
    attr_reader :current_ability, :request

    # @param [Array<String>] ids a list of ids to build presenters for
    # @param [Class] presenter_class the type of presenter to build
    # @return [Array<presenter_class>] presenters for the ordered_members (not filtered by class)
    def member_presenters(ids = ordered_ids, presenter_class = composite_presenter_class)
      a = PresenterFactory.build_for(ids: ids,
                                     presenter_class: presenter_class,
                                     presenter_args: presenter_factory_arguments)
      a.reject! { |presenter| presenter.id == @work.transcript_id.first } if @work.respond_to?(:transcript_id) && @work.transcript_id && !@work.transcript_id.first.nil?
      a
    end

    # @return [Array<FileSetPresenter>] presenters for the orderd_members that are FileSets
    def file_set_presenters
      @file_set_presenters ||= member_presenters(ordered_ids & file_set_ids)
      @file_set_presenters.reject! { |presenter| presenter.id == @work.transcript_id } if @work.respond_to?(:transcript_id) && @work.transcript_id
    end

    # @return [Array<WorkShowPresenter>] presenters for the ordered_members that are not FileSets
    def work_presenters
      @work_presenters ||= member_presenters(ordered_ids - file_set_ids, work_presenter_class)
      @work_presenters.reject! { |presenter| presenter.id == @work.transcript_id } if @work.respond_to?(:transcript_id) && @work.transcript_id
    end

    def ordered_ids
      @ordered_ids ||= Hyrax::SolrDocument::OrderedMembers.decorate(@work).ordered_member_ids
    end

    private

      # These are the file sets that belong to this work, but not necessarily
      # in order.
      # Arbitrarily maxed at 10 thousand; had to specify rows due to solr's default of 10
      def file_set_ids
        @file_set_ids ||= begin
                            ActiveFedora::SolrService.query("{!field f=has_model_ssim}FileSet",
                                                            rows: 10_000,
                                                            fl: ActiveFedora.id_field,
                                                            fq: "{!join from=ordered_targets_ssim to=id}id:\"#{id}/list_source\"")
                                                     .flat_map { |x| x.fetch(ActiveFedora.id_field, []) }
                          end
      end

      def presenter_factory_arguments
        [current_ability, request]
      end

      def composite_presenter_class
        CompositePresenterFactory.new(file_presenter_class, work_presenter_class, ordered_ids & file_set_ids)
      end
  end
end
