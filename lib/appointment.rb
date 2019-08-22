class Appointment < ActiveRecord::Base
    belongs_to :doctor
    belongs_to :patient
    # belongs_to :review

end 