# frozen_string_literal: true
class ContactController < FeedbackController
  before_action :instantiate_controller_and_action_names

  def instantiate_controller_and_action_names
    @current_action = "contact"
    @current_controller = controller_name
  end
end
