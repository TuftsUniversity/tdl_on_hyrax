require_dependency Hyrax::Engine.root.join('app', 'services', 'hyrax', 'collections', 'permissions_service').to_s

module Hyrax
  module Collections
    class PermissionsService
      # PATCH: Fixing Dangerous query method that will not be in Rails 6.0.
      # Fixed in Hyrax 3.0 - can be removed when upgrading to that.
      def self.source_ids_for_user(access:, ability:, source_type: nil, exclude_groups: [])
        scope = PermissionTemplateAccess.for_user(ability: ability, access: access, exclude_groups: exclude_groups)
                                        .joins(:permission_template)
        ids = scope.select(:source_id).distinct.pluck(:source_id)
        return ids unless source_type
        filter_source(source_type: source_type, ids: ids)
      end
      private_class_method :source_ids_for_user
    end
  end
end
