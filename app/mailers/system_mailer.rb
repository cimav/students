class SystemMailer < ActionMailer::Base
 default from: "<email@mydomain.com>"
 def notification_email(student,staff)
   @student = student
   @staff = staff
   mail(:to=> @staff.email,:subject=>"Se ha subido un archivo de avance")
 end 
end
