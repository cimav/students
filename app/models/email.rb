class Email < ActiveRecord::Base
  attr_accessible :id,:from,:to,:subject,:content,:status

  CREATED      = 0
  SENT         = 1 
  PREFERENTIAL = 99
 
  STATUS = {
   CREATED => "Creado",
   SENT    => "Enviado",
   PREFERENTIAL => "Preferencial"
  }
end
