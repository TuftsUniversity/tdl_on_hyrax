# frozen_string_literal: true
class FeedbackController < ApplicationController
  # http://expressica.com/simple_captcha/
  # include SimpleCaptcha::ControllerHelpers
  layout 'homepage'

  # show the feedback form
  def show
    @errors = []
    return unless request.post? && validate

    FeedbackMailer.feedback(params).deliver_now
  end

  # show the contact form
  def show_contact
    @errors = []
    return unless request.post? && validate

    FeedbackMailer.contact(params).deliver_now

    flash[:notice] = I18n.t('blacklight.feedback.complete')
    params[:name] = ''
    params[:email] = ''
    params[:message] = ''
  end

  protected

    # validates the incoming params
    # returns either an empty array or an array with error messages
    def validate
      @errors << I18n.t('blacklight.feedback.valid_name') unless params[:name].match?(/\w+/)
      @errors << I18n.t('blacklight.feedback.valid_email') unless params[:email].match?(/\w+@\w+\.\w+/)
      @errors << I18n.t('blacklight.feedback.need_message') unless params[:message].match?(/\w+/)
      @errors.empty?
    end
end
