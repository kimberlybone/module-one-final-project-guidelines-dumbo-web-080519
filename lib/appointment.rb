class Appointment < ActiveRecord::Base
    belongs_to :doctor
    belongs_to :patient


    def self.handle_change_appt(option)
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


    def appointment_options
        TTY::Prompt.new.select("What would you like to change about the appointment", view_appointments) do |m|
            choices = %w(view_appointments)

            TTY::Prompt.new.enum_select("Select an appointment", choices)
        end 
    end 






    # def self.handle_change_time
    # end 

    # def self.handle_change_doctor
    # end 

    # def self.handle_change_reason
    # end 


    # def self.handle_cancel
    # end 

    # def self.handle_view
    # end 




end 