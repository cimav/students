namespace :xmails do 
  desc "Send queued e-mails"
  task :send => :environment do
    email = Email.where(:status=>Email::PREFERENTIAL).order("created_at asc").first

    if email.nil?
      email = Email.where(:status=>0).order("created_at asc").first
      puts "Sending normal email to #{email.to}"
      SystemMailer.notification_email(email).deliver
    else
      puts "Sending preferential email to #{email.to}"
      SystemMailer.failed_subject(email).deliver
    end

    email.status= 1;
    email.save
  end
end
