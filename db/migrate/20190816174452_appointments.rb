class Appointments < ActiveRecord::Migration[5.0]
  def change
    create_table :appointments do |t|
      t.string :date
      t.string :time
      t.integer :doctor_id
      t.integer :patient_id
      t.string :reason
    end  
  end
end
