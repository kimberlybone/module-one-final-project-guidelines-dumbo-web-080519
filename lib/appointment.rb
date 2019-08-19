class Appointment < ActiveRecord::Base
    belongs_to :doctor
    belongs_to :patient

    def self.change_appt(option)
        case option 
        when "date"
            self.date = new_info
        when "time"
            self.time = new_info
        when "doctor"
            self.doctor = new_info
        when "reason"
            self.reason = new_info
        end 
    end
end 