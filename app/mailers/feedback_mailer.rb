class FeedbackMailer < ApplicationMailer
  default :subject => "TDL Content Feedback"

  def feedback(params)
    @params = params

    # TBD - get "to" and "subject" from settings...
    mail(:to => Rails.configuration.tdl_feedback_address,
      :from => params[:email])
  end

end
