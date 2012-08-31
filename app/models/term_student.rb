class TermStudent < ActiveRecord::Base
  belongs_to :term
  belongs_to :student
  has_many :term_course_student
  has_many :term_student_payment
  accepts_nested_attributes_for :term_course_student
  accepts_nested_attributes_for :term_student_payment

  ACTIVE   = 1
  PENDING  = 2
  INACTIVE = 3

  STATUS = {ACTIVE   => 'Activo',
            PENDING  => 'Con pendientes',
            INACTIVE => 'Baja'}

   def status_type
     STATUS[status]
   end
end
