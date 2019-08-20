
require_relative '../config/environment'

class CarePortal

    attr_accessor :prompt, :patient 
    #I made these accessors because Eric has them as accessors in his video
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
        patient.reload
        prompt.select "Please select what you would like to do." do |menu|
        menu.choice "Schedule", -> {handle_schedule}
        menu.choice "Update", -> {handle_update}
        menu.choice "Cancel", -> {cancel}
        menu.choice "View", -> {patient.pt_appointments}
        menu.choice "Quit", -> {quit}
        end 
    end

   

#check if account exists
    def check_account
        prompt.select "Do you already have an account?" do |m|
            m.choice "Yes", -> {Patient.handle_returning_user} do
                # if self.patient.nil? #if doesnt exist
                #     puts "Sorry, we don't have an account for you."
                #     prompt.select "Would you like to create one?" do |m|
                #         m.choice "Try Again", -> {Patient.handle_returning_user}
                #         m.choice "Create Account", -> {Patient.handle_new_user}
                #         m.choice "Exit", -> {quit}
                #     end
                # end 
            end
            m.choice "No", -> {Patient.handle_new_user}
        end    
    end


#gets info to create appointment
    def handle_schedule
        patient.reload
        date = prompt.ask("What day do you want to schedule your appointment for?")
        time = prompt.ask( "When time do you want to schedule your appointment for?")
        reason = prompt.ask( "What is the reason for your visit?")
        doctor_name = prompt.ask( "Which doctor do you want to schedule the appointment with?")
        @doctor = Doctor.find_by(name: doctor_name)
        if @doctor == nil
            @doctor = Doctor.create(name: doctor_name,specialty: nil)
        end
        appts = Appointment.all.select{ |appt| appt.patient_id == @patient.id}
        appts << Appointment.create(date: date, time: time, doctor: @doctor, patient: @patient, reason: reason)

        puts "Here are your appointments\n #{appts}" 
        
        # continue?
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

    # def view_appointments
    #     appts = Appointment.find_by(patient_id: patient.id)
        # appts = appts.map { |appt|
        #     appt.date
        #     appt.time
        #     appt.doctor
        #     appt.reason
    #     appts = self.appts.inject({}) do |hash, appt|
    #         hash["date"] = appt.date
    #         hash["time"] = appt.time
    #         hash["doctor"] = appt.doctor
    #         hash["reason"] = appt.reason
    #         hash
    #     end


    #     }
    # end 

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
                    specific_appt[0].doctor = new_doctor
                when 4 
                    new_reason = prompt.ask("What is the new reason?")
                    specific_appt[0].reason = new_reason
                end 
                specific_appt
            end 
    end



#I think we should use patient/doctor ID's rather than names bc it will keep adding to the list with a string but will recognize the instance with an ID


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
