# class Review < ActiveRecord::Base
#     belongs_to :appointment, through: :doctor
#     belongs_to :appointment, through: :patient
#     #create migration
#     #in migration file:
#         #def change 
#         # create_table :review do |t|
#         #     t.integer :doctor_id
#         #     t.integer :rating
#         #     t.string :review
#         #     t.integer :author
#         # end 
# end 