require_dependency Hyrax::Engine.root.join('app', 'models', 'concerns', 'hyrax', 'ability').to_s

module Hyrax
  module Ability
    private

      # PATCH: Fixing Dangerous query method that will not be in Rails 6.0.
      # # Fixed in Hyrax 3.0 - can be removed when upgrading to that.
      def admin_set_with_deposit?
        ids = PermissionTemplateAccess.for_user(ability: self,
                                                access: ['deposit', 'manage'])
                                      .joins(:permission_template)
                                      .select(:source_id)
                                      .distinct
                                      .pluck(:source_id)
        query = "_query_:\"{!raw f=has_model_ssim}AdminSet\" AND {!terms f=id}#{ids.join(',')}"
        ActiveFedora::SolrService.count(query).positive?
      end
  end
end
