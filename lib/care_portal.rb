
require_relative '../config/environment'

class CarePortal

    attr_accessor :prompt, :patient, :doctor 

    def initialize 
        @prompt = TTY::Prompt.new
    end 
# Welcomes user and if they have an account, they will continue to show menu but if they don't it will create an account
    def welcome 
        system "clear"
        puts "\u001b[35;1mWelcome to CarePortal! \u001b[0m"
        prompt.select("Do you already have an account?") do |m|
            m.choice "Yes", -> {Patient.handle_returning_user}
            m.choice "No", -> {Patient.handle_new_user}
        end 
    end 
# Menu options will show 
    def show_menu
        system "clear"
        menu_options = prompt.select("Please select what you would like to do.") do |menu|
            menu.choice "\u001b[35;1mSchedule", -> {handle_schedule}
            menu.choice "Update", -> {handle_update}
            menu.choice "View", -> {view}
            menu.choice "Cancel Appointment", -> {cancel_appointment}
            menu.choice "Quit", -> {quit}
        end 
    end
# Schedules an appointment for patient and if doctor already exists, chooses doctor. If doctor doesn't exist, adds doctor with their specialty
    def handle_schedule
        patient.reload
        system "clear"
        date = prompt.ask("\u001b[35;1m\u001b[1m What day do you want to schedule your appointment for?\u001b[0m (ex: 08-05-19)")
        time = prompt.ask("\u001b[35;1m\u001b[1m What time do you want to schedule your appointment for? \u001b[0m (ex: 10:00 am)")
        reason = prompt.ask("\u001b[35;1m\u001b[1m What is the reason for your visit?\u001b[0m")

        line_separation
        output_doctor_specialty
        line_separation
        
        prompt.select("Is your doctor already listed above?") do |m|
            m.choice 'Yes', -> {doctor_in_system} 
            m.choice 'No', -> {doctor_not_in_system}
        end 

        line_separation

        Appointment.create(date: date, time: time, doctor: @doctor, patient: @patient, reason: reason)
        system "clear"
        patient.pt_appointments
        prompt.keypress("Press any key to continue.")
        continue?
    end
# Updates appointment attributes chosen 
    def handle_update
        patient.reload 
        system "clear"
        if patient.appointments == [] 
            puts "\u001b[31;1mThere are no appointments to update. Please schedule an appointment to update!\u001b[0m"
            prompt.keypress("Press any key to continue.")
            continue?
        end 
        display_appt_options
        appt_id = prompt.select("Please select an appointment: ", display_appt_options)
        appointment = Appointment.find(appt_id)
        

        choices = {Date: 1, Time: 2, Doctor: 3, Reason: 4}
        attributes = prompt.multi_select("What do you want to change about this appointment?", choices)
            attributes.each do |attribute|
            case attribute
            when 1
                new_date = prompt.ask("What is the new date? \u001b[1m(ex: 08-05-19)\u001b[0m")
                appointment.update(date: new_date) 
            when 2
                new_time = prompt.ask("What is the new time? \u001b[1m(ex: 3:15 pm)\u001b[0m")
                appointment.update(time: new_time)
            when 3 
                output_doctor_specialty
                new_doc_obj = prompt.select("Is your doctor already listed above?") do |m|
                    m.choice 'Yes', -> {doctor_in_system} 
                    m.choice 'No', -> {doctor_not_in_system}
                end 
                appointment.doctor.update(name: new_doc_obj.name)
                #make a selection of doctors
            when 4 
                new_reason = prompt.ask("What is the new reason?")
                appointment.update(reason: new_reason)
            end 
            
            puts "\u001b[35;1m\u001b[4mDate:\u001b[0m #{appointment.date}"
            puts "\u001b[35;1m\u001b[4mTime:\u001b[0m #{appointment.time}"
            puts "\u001b[35;1m\u001b[4mDoctor:\u001b[0m #{appointment.doctor.name}"
            puts "\u001b[35;1m\u001b[4mReason:\u001b[0m #{appointment.reason}"
            line_separation      

        end 
        prompt.keypress("Press any key to continue.")
        continue?
    end
# View all appointments
    def view 
        patient.reload
        system "clear"
        if patient.appointments == []
            puts "\u001b[31;1mThere are no appointments to view. Please schedule an appointment to view!\u001b[0m"
            prompt.keypress("Press any key to continue.")
            continue?
       end 
    
        patient.pt_appointments
        prompt.keypress("Press any key to continue.")
        continue?     
    end 
# Cancels chosen appointment
    def cancel_appointment
        patient.reload 
        system "clear"
         if patient.appointments == [] 
            puts "\u001b[31;1mThere are no appointments to cancel. Please schedule an appointment to cancel!\u001b[0m"
            prompt.keypress("Press any key to continue.")
            continue?
       end 

        appt_list_w_specialty

        appt_id = prompt.select("Which appointment would you like to cancel?", appt_list_w_specialty)
        answer = prompt.yes?('Are you sure you would like to cancel this appointment?')
       
        if answer
            Appointment.destroy(appt_id)
            puts "Your appointment has been canceled"
        end
        patient.reload
        system "clear"
        patient.pt_appointments 
        prompt.keypress("Press any key to continue.")  
        continue?      
    end 

    def quit
        exit
    end 


    # def see_reviews_by_doc
        # doctor.reviews.each_with_index.inject({}) do |hash, (review, i)|
        #     hash["#{i + 1}) #{doctor.name} | #{doctor.specialty} | rating: #{review.rating} | review: #{review.description}"] = doctor.id
        #     hash
        # end
    # end 

    # def see_reviews_by_pt
        # patient.reviews.each_with_index.inject({}) do |hash, (review, i)|
        #     hash["#{i + 1}) #{patient.name} | rating: #{review.rating} | review: #{review.description}"] = patient.id
        #     hash
        # end
    # end 

    # def write_review
        #answer = prompt.yes?("Would you like to write a review?")
        # if answer
        # appt = prompt.ask("What appointment would you like to make a review for?", display_appt_options)
        # rating = prompt.ask("\u001b[35;1m\u001b[1m What rating would you give your experience?\u001b[0m (ex: 08-05-19)")
        # time = prompt.ask("\u001b[35;1m\u001b[1m What would you like to write about your experience? \u001b[0m (ex: 10:00 am)")
            
            # prompt.select("Is your doctor already in the system?") do |m|
            #     m.choice 'Yes', -> {doctor_in_system} 
            #     m.choice 'No', -> {doctor_not_in_system}
            # end 
    
            # line_separation
    #     Review.create(doctor: doctor, rating: rating, review: review, author: patient)
    # system "clear"
    # see_reviews_by_pt
    # prompt.keypress("Press any key to continue.")
    # continue?
        # end 
    # end 



    # HELPER METHODS

    def line_separation
        puts " "
        puts "-------------------------------------"
        puts " "
    end 

    def continue?
        patient.reload
        system "clear"
        prompt.select "What do you want to do now?" do |menu|
            menu.choice "Main Menu", -> {show_menu}
            menu.choice "Exit", -> {quit}
        end 
    end

    def doctor_in_system
        doctor_obj = Doctor.all.each_with_index.inject({}) do |hash, (doctor, i)|
            hash["#{i + 1}) #{doctor.name} | #{doctor.specialty}"] = doctor.id
            hash
        end

        choice = prompt.select("Please select your doctor.", doctor_obj)
        @doctor = Doctor.find(choice)
    end 


    def doctor_not_in_system
        system "clear"
        doctor_name = prompt.ask("\u001b[35;1m\u001b[1mPlease enter the doctor's name\u001b[0m (ex: Dr. John Doe): ")
        
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
            puts "\u001b[35;1mDoctor:\u001b[0m #{doctor.name} | \u001b[35;1mSpecialty:\u001b[0m #{doctor.specialty}"
        }
    end

    def appt_list_w_specialty
        patient.reload
        patient.appointments.each_with_index.inject({}) do |hash, (appointment, i)|
            this_doctor = Doctor.find(appointment.doctor_id)
            hash["#{i + 1}) \u001b[35;1m#{appointment.date}\u001b[0m | \u001b[35;1m#{this_doctor.name}\u001b[0m | \u001b[35;1m#{this_doctor.specialty}\u001b[0m"] = appointment.id
            hash
        end 
    end

    def show_appts_on_date(appt_day)
        patient.reload
        appts_on_that_day = patient.pt_appointments.pluck(date: appt_day)
    end 

    def display_appt_options
        patient.reload
        patient.appointments.each_with_index.inject({}) do |hash, (appointment, i)|
            this_doctor = Doctor.find(appointment.doctor_id)
            hash["#{i + 1}) \u001b[35;1m#{appointment.date}\u001b[0m | #{appointment.time} | #{this_doctor.name} | #{this_doctor.specialty} | #{appointment.reason}"] = appointment.id
            hash
        end
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
