class CreateReviews < ActiveRecord::Migration[5.0]
  def change
    create_table :reviews do |t|
      t.integer :rating
      t.string :content
      t.integer :doctor_id
      t.integer :patient_id
    end
  end
end
