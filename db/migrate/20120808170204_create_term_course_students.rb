class CreateTermCourseStudents < ActiveRecord::Migration
  def change
    create_table :term_course_students do |t|

      t.timestamps
    end
  end
end
