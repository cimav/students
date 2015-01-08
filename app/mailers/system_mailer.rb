class SystemMailer < ActionMailer::Base
 default :from  => "atencion.posgrado@cimav.edu.mx"
 def notification_email(object)
   @hash       = eval object.content
   @to        = object.to
   mail(:to=> @to,:subject=>object.subject)
 end 
end
