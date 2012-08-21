class TermCourseStudent < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :term_course
  belongs_to :term_student

  ACTIVE   = 1
  INACTIVE = 2

  STATUS = {ACTIVE   => 'Activo',
            INACTIVE => 'Baja'}

  def status_type
    STATUS[status]
  end

end
