
require_relative '../config/environment'

class CarePortal

    attr_accessor :prompt, :patient, :doctor 

    def initialize 
        @prompt = TTY::Prompt.new
    end 

    def line_separation
        puts " "
        puts "-------------------------------------"
        puts " "
    end 

    def welcome 
        system "clear"
        puts "Welcome to CarePortal!"
        prompt.select("Do you already have an account?") do |m|
            m.choice "Yes", -> {Patient.handle_returning_user}
            m.choice "No", -> {Patient.handle_new_user}
        end 
    end 

    def show_menu
        system "clear"
        menu_options = prompt.select "Please select what you would like to do." do |menu|
            menu.choice "Schedule", -> {handle_schedule}
            menu.choice "Update", -> {handle_update}
            menu.choice "View", -> {view}
            menu.choice "Cancel Appointment", -> {cancel_appointment}
            menu.choice "Quit", -> {quit}
        end 
    end


    def view 
        patient.reload
        system "clear"
        patient.pt_appointments
        continue?
      
    end 

    def doctor_in_system
        doctor_list = Doctor.all.each_with_index.inject({}) do |hash, (doctor, i)|
            hash["#{i + 1}) #{doctor.name} | #{doctor.specialty}"] = doctor.id
            hash
        end

        choice = prompt.select("Please select your doctor.", doctor_list)
        @doctor = Doctor.find(choice)
    end 


    def doctor_not_in_system
        system "clear"
        doctor_name = prompt.ask("Please enter the doctor's name (ex: Dr. John Doe): ")
        
        @doctor = Doctor.create(name: doctor_name, specialty: nil)

        choices = {Cardiovascular: 1, Neurology: 2, Pulmonology: 3, Ophthalmology: 4, Orthodontal: 5, Gyneocology: 6, Family: 7, Pediatrics: 8, Dermatology: 9}
        dr_specialty = prompt.select("Please choose a specialty for your doctor (Scroll down): ", choices)
    
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
            puts "Doctor: #{doctor.name} | Specialty: #{doctor.specialty}"
        }
    end


    def appt_list_w_specialty
        patient.reload
        patient.appointments.each_with_index.inject({}) do |hash, (appointment, i)|
            this_doctor = Doctor.find(appointment.doctor_id)
            hash["#{i + 1}) #{appointment.date} | #{this_doctor.name} | #{this_doctor.specialty}"] = appointment.id
            hash
        end 
    end


    def handle_schedule
        patient.reload
        system "clear"
        date = prompt.ask("What day do you want to schedule your appointment for? (ex: 08-05-19)")
        time = prompt.ask( "What time do you want to schedule your appointment for? (ex: 10:00 am)")
        reason = prompt.ask( "What is the reason for your visit?")

        line_separation

        output_doctor_specialty

        line_separation
        
        prompt.select("Is your doctor already in the system?") do |m|
            m.choice 'Yes', -> {doctor_in_system} 
            m.choice 'No', -> {doctor_not_in_system}
        end 

        line_separation

        Appointment.create(date: date, time: time, doctor: @doctor, patient: @patient, reason: reason)
        system "clear"
        patient.pt_appointments
        continue?
    end

    def continue?
        patient.reload
        system "clear"
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

    def display_appt_options
        patient.reload
        patient.appointments.each_with_index.inject({}) do |hash, (appointment, i)|
            this_doctor = Doctor.find(appointment.doctor_id)
            hash["#{i + 1}) #{appointment.date} | #{appointment.time} | #{this_doctor.name} | #{this_doctor.specialty} | #{appointment.reason}"] = appointment.id
            hash
        end
    end 


    def handle_update
        patient.reload 
        system "clear"

        display_appt_options

        appt_id = prompt.select("Please select an appointment: ", display_appt_options)
        appointment = Appointment.find(appt_id)
        

        choices = {Date: 1, Time: 2, Doctor: 3, Reason: 4}
        attributes = prompt.multi_select("What do you want to change about this appointment?", choices)
            attributes.each do |attribute|
                case attribute
                when 1
                    new_date = prompt.ask("What is the new date? (ex: 08-05-19)")
                    appointment.update(date: new_date) 
                when 2
                    new_time = prompt.ask("What is the new time? (ex: 3:15 pm)")
                    appointment.update(time: new_time)
                when 3 
                    new_doctor_name = prompt.ask("What is the new doctor? (ex: Dr. Bill Smith)")
                    appointment.doctor.update(name: new_doctor_name)
                    #make a selection of doctors
                when 4 
                    new_reason = prompt.ask("What is the new reason?")
                    appointment.update(reason: new_reason)
                end 
                # system "clear"
             
                puts "Date: #{appointment.date}"
                puts "Time: #{appointment.time}"
                puts "Doctor: #{appointment.doctor.name}"
                puts "Reason: #{appointment.reason}"

                line_separation           
            end 
            continue?
    end

    def cancel_appointment
        patient.reload 
        system "clear"

        appt_list_w_specialty

        appt_id = prompt.select("Which appointment would you like to cancel?", appt_list_w_specialty)

        answer = prompt.yes?('Are you sure you would like to cancel this appointment?')
       
        if answer
            Appointment.destroy(appt_id)
            puts "Your appointment has been cancelled"
        end
        system "clear"
        patient.pt_appointments
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
