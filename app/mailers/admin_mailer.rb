class AdminMailer < ActionMailer::Base
  default :to => "feedback@dreamcatcher.net"
  
  def feedback_email(user, feedback)
    @user = user
    @feedback = feedback[:body]
    feedback_type = feedback[:type]  
    feedback_type += " // #{feedback[:bug_type]}" if (feedback[:type]=='bug')
    
    mail(from: user.email, subject: "Feedback: #{feedback_type}")
  end
end
