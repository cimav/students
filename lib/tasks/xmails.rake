namespace :xmails do 
  desc "Send queued e-mails"
  task :send => :environment do
    email = Email.where(:status=>0).order("created_at asc").first
    puts "Sending email to #{email.to}"
    SystemMailer.notification_email(email).deliver
    email.status= 1;
    email.save
  end
end
