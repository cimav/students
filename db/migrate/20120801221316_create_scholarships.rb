class CreateScholarships < ActiveRecord::Migration
  def change
    create_table :scholarships do |t|

      t.timestamps
    end
  end
end
