# -*- encoding : utf-8 -*-
class FeedbackController < ApplicationController
  # http://expressica.com/simple_captcha/
  # include SimpleCaptcha::ControllerHelpers

  # show the feedback form
  def show
    @errors = []
    FeedbackMailer.feedback(params).deliver_now if request.post? && validate
  end

  protected

    # validates the incoming params
    # returns either an empty array or an array with error messages
    def validate
      @errors << I18n.t('blacklight.feedback.valid_name') unless params[:name] =~ /\w+/
      @errors << I18n.t('blacklight.feedback.valid_email') unless params[:email] =~ /\w+@\w+\.\w+/
      @errors << I18n.t('blacklight.feedback.need_message') unless params[:message] =~ /\w+/
      # unless simple_captcha_valid?
      #  @errors << 'Captcha did not match'
      # end
      @errors.empty?
    end
end
