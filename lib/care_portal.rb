
require_relative '../config/environment'

class CarePortal
    def initialize 
        @prompt = TTY::Prompt.new
    end 

    def welcome 
        puts "Welcome to CarePortal!"
    end 

    def show_menu
        @prompt.select "Please select what you would like to do." do |menu|
        menu.choice "Schedule", -> {schedule}
        menu.choice "Update", -> {update}
        menu.choice "Cancel", -> {cancel}
        menu.choice "View", -> {view}
        menu.choice "Quit", -> {quit}
        end 
    end

#check if account exists
    def check_account
        @prompt.select "Do you already have an account?" do |m|
            m.choice "Yes", -> {returning_user} do
                if @patient.nil? #if doesnt exist
                    puts "Sorry, we don't have an account for you."
                    @prompt.select "Would you like to create one?" do |m|
                        m.choice "Try Again", -> {returning_user}
                        m.choice "Create Account", -> {create_account(@patient_name)}
                        m.choice "Exit", -> {quit}
                    end 
                    puts "check_account reached"
                end 
            end
            m.choice "No", -> {create_account}
        end    
    end

    def new_user

    end

# If the user already has an account, will find patient using name they entered
    def returning_user
        @patient_name = @prompt.ask("Please enter your name")
        @patient = Patient.find_by(name: patient_name)

    end

    def create_account(name)
        @patient = Patient.create(name: name)
    end 

    # def update
    # end

    # def cancel
    # end

    

    def change_appt(appointment, key, value)
        case key 
        when "date"
            appointment.date = value
        when "time"
            appointment.time = value
        when "doctor"
            appointment.doctor = value
        when "reason"
            appointment.reason = value
        end 
    end 
#gets info to create appointment
    def schedule
        date = @prompt.ask("What day do you want to schedule your appointment for?")
        time = @prompt.ask( "When time do you want to schedule your appointment for?")
        reason = @prompt.ask( "What is the reason for your visit?")
        doctor_name = @prompt.ask( "Which doctor do you want to schedule the appointment with?")
        @doctor = Doctor.find_by(name: doctor_name)
        if @doctor == nil
            @doctor = Doctor.create(name: doctor_name,specialty: nil)
        end
        @patient.appointments << Appointment.create(date: date, time: time, doctor: @doctor, patient: @patient, reason: reason)
        puts "schedule"

        # @patient.appointments
        # continue?
    end

    def continue?
        @prompt.select "What do you want to do now?" do |menu|
            menu.choice "Main Menu", -> {show_menu}
            menu.choice "Exit", -> {quit}
        end 
    end

    def quit
        exit
    end 

    def update 

        option = @prompt.select "Please select what you would like to do." do |menu|
            menu.choice "Date", -> {change_appt()}
            menu.choice "Time", -> {update}
            menu.choice "Doctor", -> {cancel}
            menu.choice "Reason", -> {view}
            menu.choice "Quit", -> {quit}
            end
            
        #    user =  @prompt.select "Please select what you would like to do."  [returning user, new user]
        
        
        # @prompt.select "What appointment would you like to update?" do |m|
        #     show_appointments(@patient)
            
        #     @patient.appointments.each do |appt|
        #         m.choice appt, -> {appt.change_appt()}
        #     end 
        #     m.choice "Go Back", -> {show_menu}
        # end 
    end 

end 
