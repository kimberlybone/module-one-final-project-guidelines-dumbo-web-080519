#CARE PORTAL 
#Authors: Kimberly Bone and Zermina Ejaz
#Our app is a portal for patients and doctors to be able to view, update, cancel, and schedule appointments. Menu features come from TTY:Prompt. This app allows for a better way to communicate between patient and doctor 



require_relative '../config/environment'

class CarePortal

    attr_accessor :prompt, :patient, :doctor, :path

    def initialize 
        @prompt = TTY::Prompt.new
    end 
# Welcomes user and if they have an account, they will continue to show menu but if they don't it will create an account
    def welcome 
        system "clear"
        puts "\u001b[35;1mWelcome to CarePortal! \u001b[0m"

        user_type = prompt.select("Are you a Patient or a Doctor?") do |m|
            m.choice "Patient"
            m.choice "Doctor"
        end
        case user_type
        when "Patient"
            @path = "Patient"
            prompt.select("Do you already have an account?") do |m|
                m.choice "Yes", -> {Patient.handle_returning_user}
                m.choice "No", -> {Patient.handle_new_user}
            end
        when "Doctor"
            @path = "Doctor"
            prompt.select("Do you already have an account?") do |m|
                m.choice "Yes", -> {Doctor.handle_returning_user}
                m.choice "No", -> {Doctor.handle_new_user}
            end
        end 
    end
#######################################################################################################
# PATIENT PATHWAY
# Menu options will show 
    def show_menu
        system "clear"
        if @path == "Patient"
            menu_options = prompt.select("Please select what you would like to do.") do |menu|
                menu.choice "\u001b[35;1mSchedule", -> {handle_schedule} #check, create handle schedul emethod depending on patient or doctor
                menu.choice "Update", -> {handle_update}
                menu.choice "View", -> {view}
                menu.choice "Cancel Appointment", -> {cancel_appointment}
                menu.choice "Quit", -> {quit}
            end 
        elsif @path == "Doctor"
            doctor.reload
            menu_options = prompt.select("Please select what you would like to do.") do |menu|
                menu.choice "\u001b[35;1mSchedule", -> {doctor_schedules_appt} #check, create handle schedul emethod depending on patient or doctor
                menu.choice "Update", -> {doctor_handle_update}
                menu.choice "View", -> {doctor_view}
                menu.choice "Cancel Appointment", -> {doc_cancel_appointment}
                menu.choice "Quit", -> {quit}
            end 
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
            puts "\u001b[1m\u001b[4mPatient:\u001b[0m #{appointment.patient.name}"
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



###########################################################################################
# DOCTOR PATHWAY


    def doctor_schedules_appt
        doctor.reload
        system "clear"
        date = prompt.ask("\u001b[35;1m\u001b[1m What day do you want to schedule the appointment with the patient?\u001b[0m (ex: 08-05-19)")
            puts ""
        time = prompt.ask("\u001b[35;1m\u001b[1m What time do you want to schedule the appointment with the patient? \u001b[0m (ex: 10:00 am)")
            puts ""
        reason = prompt.ask("\u001b[35;1m\u001b[1m What do you need to see the patient for?\u001b[0m")

        line_separation
        output_patient_info

        line_separation
        
        prompt.select("Is your Patient already listed above?") do |m|
            m.choice 'Yes', -> {patient_in_system} 
            m.choice 'No', -> {patient_not_in_system}
        end 

        line_separation

        Appointment.create(date: date, time: time, doctor: doctor, patient: patient, reason: reason)
        system "clear"
        doctor.dc_appointments
        prompt.keypress("Press any key to continue.")
        doc_continue?
    end
# Updates appointment attributes chosen 
    def doctor_handle_update
        doctor.reload 
        system "clear"
        if doctor.appointments == [] 
            puts "\u001b[31;1mThere are no appointments to update. Please schedule an appointment to update!\u001b[0m"
            prompt.keypress("Press any key to continue.")
            doc_continue?
        end 
        display_doc_appt_options #come back
        appt_id = prompt.select("Please select an appointment: ", display_doc_appt_options)
        appointment = Appointment.find(appt_id)
        

        choices = {Date: 1, Time: 2, Patient: 3, Reason: 4}
        attributes = prompt.multi_select("What do you want to change about this appointment?", choices)
            attributes.each do |attribute|
            case attribute
            when 1
                new_date = prompt.ask("What is the new date? \u001b[1m(ex: 08-05-19)\u001b[0m")
                appointment.update(date: new_date) 
                puts ""
            when 2
                new_time = prompt.ask("What is the new time? \u001b[1m(ex: 3:15 pm)\u001b[0m")
                appointment.update(time: new_time)
                puts ""
            when 3 
                system "clear"
                output_patient_info
                new_pt_obj = prompt.select("Is your patient already listed above?") do |m|
                    m.choice 'Yes', -> {patient_in_system} 
                    m.choice 'No', -> {patient_not_in_system}
                end 
                appointment.patient.update(name: new_pt_obj.name)
                #make a selection of patients
            when 4 
                new_reason = prompt.ask("What is the new reason?")
                appointment.update(reason: new_reason)
                puts ""
            end 
            
            puts "\u001b[35;1m\u001b[4mDate:\u001b[0m #{appointment.date}"
            puts "\u001b[35;1m\u001b[4mTime:\u001b[0m #{appointment.time}"
            puts "\u001b[35;1m\u001b[4mPatient:\u001b[0m #{appointment.patient.name}"
            puts "\u001b[35;1m\u001b[4mReason:\u001b[0m #{appointment.reason}"

            
            line_separation      
        end 
        prompt.keypress("Press any key to continue.")
        doc_continue?
    end


    def doctor_view
        doctor.reload
        system "clear"
        if doctor.appointments == []
            puts "\u001b[31;1mThere are no appointments to view. Please schedule an appointment to view!\u001b[0m"
            prompt.keypress("Press any key to continue.")
            doc_continue?
        end 
        doctor.dc_appointments
        prompt.keypress("Press any key to continue.")
        doc_continue? 
    end 
#cancels appointment with patient
    def doc_cancel_appointment
        doctor.reload 
        system "clear"
        if doctor.appointments == [] 
            puts "\u001b[31;1mThere are no appointments to cancel. Please schedule an appointment to cancel!\u001b[0m"
            prompt.keypress("Press any key to continue.")
            doc_continue?
        end 

        display_doc_appt_options
        appt_id = prompt.select("Which appointment would you like to cancel?", display_doc_appt_options)
        answer = prompt.yes?('Are you sure you would like to cancel this appointment with this patient?')
    
        if answer
            Appointment.destroy(appt_id)
            puts "Your appointment has been canceled"
        end
        doctor.reload
        system "clear"
        doctor.dc_appointments 
        prompt.keypress("Press any key to continue.")  
        doc_continue?      
    end 

    def quit
        exit
    end 

    # def see_reviews_of_doc
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
        # doc = prompt.ask("What doctor would you like to make a review for?", display_appt_options)
        # rating = prompt.ask("\u001b[35;1m\u001b[1m What rating would you give your experience?\u001b[0m (ex: 08-05-19)")
        # review = prompt.ask("\u001b[35;1m\u001b[1m What would you like to write about your experience? \u001b[0m (ex: 10:00 am)")
            
            # prompt.select("Is your doctor already in the system?") do |m|
            #     m.choice 'Yes', -> {doctor_in_system} 
            #     m.choice 'No', -> {doctor_not_in_system}
            # end 
    
            # line_separation
    #     Review.create(doctor: doc, rating: rating, review: review, author: patient)
    # system "clear"
    # see_reviews_by_pt
    # prompt.keypress("Press any key to continue.")
    # continue?
        # end 
    # end 


###########################################################################################
    # HELPER METHODS FOR PATIENT

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

        choices = %w(Cardiovascular, Neurology, Pulmonology, Ophthalmology, Orthodontal, Gyneocology, Family, Pediatrics, Dermatology)
        dr_specialty = prompt.select("Please choose a specialty for your doctor (Scroll down): ", choices)
        
        @doctor.update(specialty: dr_specialty)

        # case dr_specialty
        # when 1
        # when 2
        #     @doctor.update(specialty: "Neurology")
        # when 3 
        #     @doctor.update(specialty: "Pulmonology")
        # when 4 
        #     @doctor.update(specialty: "Ophthalmology")
        # when 5
        #     @doctor.update(specialty: "Orthodontal")
        # when 6
        #     @doctor.update(specialty: "Gyneocology")
        # when 7
        #     @doctor.update(specialty: "Family")
        # when 8
        #     @doctor.update(specialty: "Pediatrics")
        # when 9
        #     @doctor.update(specialty: "Dermatology")
        # end
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

##############################################################################################################
#HELPER METHODS FOR DOC

    def output_patient_info
        Patient.all.map{ |patient|
            puts "\u001b[35;1mPatient:\u001b[0m #{patient.name}"
        }
    end

    def patient_in_system
        patient_obj = Patient.all.each_with_index.inject({}) do |hash, (patient, i)|
            hash["#{i + 1}) #{patient.name}"] = patient.id
            hash
        end

        choice = prompt.select("Please select your patient.", patient_obj)
        @patient = Patient.find(choice)
    end

    def patient_not_in_system
        system "clear"
        patient_name = prompt.ask("\u001b[35;1m\u001b[1mPlease enter the patient's name\u001b[0m (ex: John Doe): ")
        
        @patient = Patient.create(name: patient_name)
    end 
    def display_doc_appt_options
        doctor.reload
        doctor.appointments.each_with_index.inject({}) do |hash, (appointment, i)|
            this_patient = appointment.patient
            hash["#{i + 1}) \u001b[35;1m#{appointment.date}\u001b[0m | #{appointment.time} | #{this_patient.name} | #{appointment.reason}"] = appointment.id
            hash
        end
    end 

    def doc_continue?
        doctor.reload
        system "clear"
        prompt.select "What do you want to do now?" do |menu|
            menu.choice "Main Menu", -> {show_menu}
            menu.choice "Exit", -> {quit}
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
