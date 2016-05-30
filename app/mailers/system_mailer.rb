class SystemMailer < ActionMailer::Base
 default :from  => "atencion.posgrado@cimav.edu.mx"
 def notification_email(object)
   @hash      = eval object.content
   @to        = object.to
 
   @reply_to  = @hash[:reply_to] rescue nil

   if @reply_to.nil?
     mail(:to=> @to,:subject=>object.subject)
   else
     mail(:to=> @to,:subject=>object.subject,:reply_to=>@reply_to)
   end
 end 
end
