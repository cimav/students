class CreateStudentAdvancesFileMessages < ActiveRecord::Migration
  def change
    create_table :student_advances_file_messages do |t|

      t.timestamps
    end
  end
end
