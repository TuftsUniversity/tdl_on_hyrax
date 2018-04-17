class FeedbackMailer < ApplicationMailer
  default :from => "donotreply@dl.tufts.edu"

  def feedback(params)
    @params = params

    # TBD - get "to" and "subject" from settings...
    mail(:to => "brian.goodmon@tufts.edu",
      :from => params[:email],
      :subject => "TDL Content Feedback")
  end

end
