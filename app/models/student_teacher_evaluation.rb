class StudentTeacherEvaluation < ActiveRecord::Base
  attr_accessible :student_id, :staff_id, :term_course_id
end
