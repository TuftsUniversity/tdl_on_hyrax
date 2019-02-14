class FeedbackMailer < ApplicationMailer

  def feedback(params)
    @params = params

    mail(to: Rails.configuration.tdl_feedback_address,
         from: params[:email],
         subject: Rails.configuration.tdl_feedback_subject)
  end


  def contact(params)
    @params = params

    mail(to: Rails.configuration.tdl_contact_address,
         from: params[:email],
         subject: Rails.configuration.tdl_contact_subject)
  end
end
