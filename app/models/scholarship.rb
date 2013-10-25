class Scholarship < ActiveRecord::Base
 attr_accessible :id,:student_id,:start_date,:end_date,:status,:notes,:created_at,:updated_at,:scholarship_type_id,:amount,:institution_id,:department_id,:other_department,:scholarship_types_attributes
 default_scope joins(:student).where('students.deleted=?',0)

 belongs_to :student
 belongs_to :scholarship_type
end
