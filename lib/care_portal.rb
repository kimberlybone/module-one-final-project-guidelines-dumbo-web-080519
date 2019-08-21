
require_relative '../config/environment'

class CarePortal

    attr_accessor :prompt, :patient, :doctor 

    def initialize 
        @prompt = TTY::Prompt.new
    end 

    def welcome 
        puts "Welcome to CarePortal!"
       self.prompt.select("Do you already have an account?") do |m|
            m.choice "Yes", -> {Patient.handle_returning_user}
            m.choice "No", -> {Patient.handle_new_user}
        end 
    end 

    def show_menu
        system "clear"
        patient.reload
        prompt.select "Please select what you would like to do." do |menu|
        menu.choice "Schedule", -> {handle_schedule}
        menu.choice "Update", -> {handle_update}
        menu.choice "Cancel", -> {cancel}
        menu.choice "View", -> {patient.pt_appointments}
        menu.choice "Quit", -> {quit}
        end 
    end

    def doctor_in_system
        doctor_list = Doctor.all.each_with_index.inject({}) do |hash, (doctor, i)|
            hash["#{i + 1}) #{doctor.name} - #{doctor.specialty}"] = doctor.id
            hash
        end

        choice = prompt.select("Please select your doctor.", doctor_list)
        @doctor = Doctor.find(choice)
    end 


    def doctor_not_in_system
        system "clear"
        doctor_name = prompt.ask("Please enter the doctor's name: ")
        
        @doctor = Doctor.create(name: doctor_name, specialty: nil)

        choices = {Cardiovascular: 1, Neurology: 2, Pulmonology: 3, Ophthalmology: 4, Orthodontal: 5, Gyneocology: 6, Family: 7, Pediatrics: 8, Dermatology: 9}
        dr_specialty = prompt.select("Please choose a specialty for your doctor", choices)
    
        case dr_specialty
        when 1
            @doctor.update(specialty: "Cardiovascular")
        when 2
            @doctor.update(specialty: "Neurology")
        when 3 
            @doctor.update(specialty: "Pulmonology")
        when 4 
            @doctor.update(specialty: "Ophthalmology")
        when 5
            @doctor.update(specialty: "Orthodontal")
        when 6
            @doctor.update(specialty: "Gyneocology")
        when 7
            @doctor.update(specialty: "Family")
        when 8
            @doctor.update(specialty: "Pediatrics")
        when 9
            @doctor.update(specialty: "Dermatology")
        end
    end 

    def output_doctor_specialty
        Doctor.all.map{ |doctor|
            puts "Doctor: #{doctor.name} Specialty: #{doctor.specialty}"
        }
    end

    def handle_schedule
        system "clear"
        patient.reload
        date = prompt.ask("What day do you want to schedule your appointment for?")
        time = prompt.ask( "What time do you want to schedule your appointment for?")
        reason = prompt.ask( "What is the reason for your visit?")

        output_doctor_specialty
        
        prompt.select("Is your doctor already in the system?") do |m|
            m.choice 'Yes', -> {doctor_in_system} 
            m.choice 'No', -> {doctor_not_in_system}
        end 
    
        Appointment.create(date: date, time: time, doctor: @doctor, patient: @patient, reason: reason)

        puts "Here are your appointments: " 
        puts " "
        @patient.appointments.each do |appt|
            puts "Date: #{appt.date}"
            puts "Time: #{appt.time}"
            puts "Doctor: #{appt.doctor.name}"
            puts "Specialty: #{appt.doctor.specialty}"
            puts "Reason: #{appt.reason}"
            puts "-----------------------------------" 
        end
        continue?
    end

    def continue?
        prompt.select "What do you want to do now?" do |menu|
            menu.choice "Main Menu", -> {show_menu}
            menu.choice "Exit", -> {quit}
        end 
    end

    def quit
        exit
    end 

    def show_appts_on_date(appt_day)
        patient.reload
        appts_on_that_day = patient.pt_appointments.pluck(date: appt_day)
    end 

    def handle_update
        patient.reload 
        appt_day = prompt.select("Select an appointment", patient.pt_appointments.pluck(:date))
        specific_appt= patient.pt_appointments.select { |appt| appt.date == appt_day}
        choices = {date: 1, time: 2, doctor: 3, reason: 4}
        attributes = prompt.multi_select("What do you want to change about this appointment?", choices)
            attributes.each do |attribute|
                case attribute
                when 1
                    new_date = prompt.ask("What is the new date?")
                    specific_appt[0].date = new_date
                when 2
                    new_time = prompt.ask("What is the new time?")
                    specific_appt[0].time = new_time
                when 3 
                    new_doctor = prompt.ask("What is the new doctor?")
                    specific_appt[0].doctor.name = new_doctor
                when 4 
                    new_reason = prompt.ask("What is the new reason?")
                    specific_appt[0].reason = new_reason
                end 

                specific_appt.each do |appt|
                    puts "Date: #{appt.date}"
                    puts "Time: #{appt.time}"
                    puts "Doctor: #{appt.doctor.name}"
                    puts "Reason: #{appt.reason}"
                    puts " "
                    puts "-----------------------"
                end 
            end 
            continue?
    end

    def cancel
        patient.reload 
        appt_day = prompt.select("Select an appointment", patient.pt_appointments.pluck(:date))
        specific_appt= patient.pt_appointments.select { |appt| appt.date == appt_day}

        specific_appt.each do |appt|
            puts "date: #{appt.date}"
            puts "time: #{appt.time}"
            puts "doctor: #{appt.doctor.name}"
            puts "reason: #{appt.reason}\n"
            puts " "
        end
        
        answer = prompt.yes?('Are you sure you would like to cancel this appointment?')
       
        if answer
            Appointment.destroy(specific_appt[0].id)
            puts "Your appointment has been cancelled"
        end
        continue?
    end 





# result = prompt.collect do
#     key(:name).ask('Name?')
  
#     key(:age).ask('Age?', convert: :int)
            
        #    user =  self.prompt.select "Please select what you would like to do."  [returning user, new user]
        
        
        # self.prompt.select "What appointment would you like to update?" do |m|
        #     show_appointments(@patient)
            
        #     @patient.appointments.each do |appt|
        #         m.choice appt, -> {appt.change_appt()}
        #     end 
        #     m.choice "Go Back", -> {show_menu}
        # end 
    # end 

end 
