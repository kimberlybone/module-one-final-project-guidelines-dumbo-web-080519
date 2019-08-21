class Patient < ActiveRecord::Base
    has_many :appointments
    has_many :doctors, through: :appointments

    def self.handle_returning_user
        puts "Please enter your name."
        name = gets.chomp
        Patient.find_by(name: name)

    end

    def self.handle_new_user
        puts "What is your name?"
        name = gets.chomp
        Patient.create(name: name)
        puts "Welcome #{name}, we have created an account for you!"
        Patient.find_by(name: name)
    end

    def pt_appointments
        # appts = Appointment.all.select do |appt|
        #     appt.patient_id == self.id
        # end
        puts "Here are your appointments: "
        puts " "
        self.appointments.each do |appt|
            puts "date: #{appt.date}"
            puts "time: #{appt.time}"
            puts "doctor: #{appt.doctor.name}"
            puts "reason: #{appt.reason}"
            puts ""
            puts "------------------------------"
        end 
    end 

    # def view_appointments
        # self.pt_appointments.inject({}) do |hash, appt|
        #     hash["date"] = appt.date
        #     hash["time"] = appt.time
        #     hash["doctor"] = appt.doctor
        #     hash["reason"] = appt.reason
        #     hash
        # end
    # end 

    #self.team.pluck(:name) OR Patient.pluck(:name)
end 