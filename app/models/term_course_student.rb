class TermCourseStudent < ActiveRecord::Base
  attr_accessible :id,:term_course_id,:term_student_id,:grade,:status,:created_at,:updated_at
  validates_uniqueness_of :term_course_id, scope: [:term_student_id]
  
  #default_scope joins(:term_student=>[:student]).where('students.deleted=?',0).readonly(false)

  belongs_to :term_course
  belongs_to :term_student

  ACTIVE      = 1
  INACTIVE    = 2
  PENROLLMENT = 6

  STATUS = {ACTIVE      => 'Activo',
            INACTIVE    => 'Baja',
            PENROLLMENT => 'Pre-inscrito'}

  def status_type
    STATUS[status]
  end

end
