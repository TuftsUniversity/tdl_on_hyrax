module WithShowEnforcement
  extend ActiveSupport::Concern
  included do
    def enforce_show_permissions(_opts = {})
      permissions = current_ability.permissions_doc(params[:id])
      unless can? :read, permissions
        raise Blacklight::AccessControls::AccessDenied.new('You do not have sufficient access privileges to read this document, which has been marked private.', :read, params[:id])
      end
      permissions
    end
  end
end
