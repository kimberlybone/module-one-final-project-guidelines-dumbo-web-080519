class Patient < ActiveRecord::Base
    has_many :appointments
    has_many :reviews
    has_many :doctors, through: :appointments

    # def handle_schedule
    #     self.reload
    #     system "clear"
    #     date = prompt.ask("\u001b[35;1m\u001b[1m What day do you want to schedule your appointment for?\u001b[0m (ex: 08-05-19)")
    #     time = prompt.ask("\u001b[35;1m\u001b[1m What time do you want to schedule your appointment for? \u001b[0m (ex: 10:00 am)")
    #     reason = prompt.ask("\u001b[35;1m\u001b[1m What is the reason for your visit?\u001b[0m")

    #     line_separation
    #     CarePortal.output_doctor_specialty
    #     line_separation
        
    #     prompt.select("Is your doctor already listed above?") do |m|
    #         m.choice 'Yes', -> {CarePortal.doctor_in_system} 
    #         m.choice 'No', -> {CarePortal.doctor_not_in_system}
    #     end 

    #     line_separation

    #     Appointment.create(date: date, time: time, doctor: cli.doctor, patient: self, reason: reason)
    #     system "clear"
    #     pt_appointments
    #     prompt.keypress("Press any key to continue.")
    #     continue?
    # end



    def self.handle_returning_user
        puts "Please enter your name."
        name = gets.chomp
        Patient.find_by(name: name)
    end

    def self.handle_new_user
        puts "What is your name?"
        name = gets.chomp
        new_patient = Patient.create(name: name)
        puts "\u001b[35;1mWelcome #{name}, we have created an account for you!\u001b[0m"
        pt = Patient.find_by(name: new_patient.name)
        TTY::Prompt.new.keypress("Press any key to continue.")
        return pt
    end

    def pt_appointments
        puts " "
        puts "\u001b[35;1m\u001b[1m\u001b[4mHere are your appointments: \u001b[0m"
        puts " "
        self.appointments.each do |appt|
            puts "\u001b[1m\u001b[4mDate:\u001b[0m #{appt.date}"
            puts "\u001b[1m\u001b[4mTime:\u001b[0m #{appt.time}"
            puts ""
            puts "\u001b[1m\u001b[4mReason:\u001b[0m #{appt.reason}"
            puts ""
            puts "\u001b[1m\u001b[4mDoctor:\u001b[0m #{appt.doctor.name}"
            puts "\u001b[1m\u001b[4mSpecialty:\u001b[0m #{appt.doctor.specialty}"
            puts ""
            puts "------------------------------"
            puts ""
        end 
    end 

end 