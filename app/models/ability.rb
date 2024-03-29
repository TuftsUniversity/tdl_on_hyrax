# frozen_string_literal: true
class Ability
  include Hydra::Ability

  include Hyrax::Ability
  self.ability_logic += [:everyone_can_create_curation_concerns]

  # Define any customized permissions here.
  def custom_permissions
    # Limits deleting objects to a the admin user
    #
    # if current_user.admin?
    #   can [:destroy], ActiveFedora::Base
    # end

    # Limits creating new objects to a specific group
    #
    # if user_groups.include? 'special_group'
    #   can [:create], ActiveFedora::Base
    # end
    can [:create, :show, :add_user, :remove_user, :index, :edit, :update, :destroy], Role if current_user.admin?

    can [:fa_overview], ActiveFedora::Base
    can [:advanced], ActiveFedora::Base
    can [:streets], ActiveFedora::Base
    can [:pdf_page], ActiveFedora::Base
    can [:pdf_page_metadata], ActiveFedora::Base
    can [:bookreader], ActiveFedora::Base
    can [:imageviewer], ActiveFedora::Base
    can [:streetsviewer], ActiveFedora::Base
    can [:fa_series], ActiveFedora::Base
    can [:audio_transcriptonly], ActiveFedora::Base
    can [:video_transcriptonly], ActiveFedora::Base
  end
end
