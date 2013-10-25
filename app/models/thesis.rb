class Thesis < ActiveRecord::Base
  attr_accessible :id,:student_id,:number,:consecutive,:title,:abstract,:defence_date,:examiner1,:examiner2,:examiner3,:examiner4,:examiner5,:status,:notes,:created_at,:updated_at
  default_scope joins(:student).where('students.deleted=?',0)

  belongs_to :student

  CONCLUDED   = 'C'
  IN_PROGRESS = 'P'
  INACTIVE    = 'I'

  STATUS = {CONCLUDED   => 'Concluida',
            IN_PROGRESS => 'En progreso',
            INACTIVE    => 'Inactiva'}

  def status_type
    STATUS[status]
  end

end
