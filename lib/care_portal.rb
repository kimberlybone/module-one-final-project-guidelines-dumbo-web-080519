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
            puts "You are logged in as a Patient."
            menu_options = prompt.select("Please select what you would like to do.\n") do |menu|
                menu.choice "\u001b[35;1mSchedule Appointment", -> {handle_schedule} #check, create handle schedul emethod depending on patient or doctor
                menu.choice "Update Appointment", -> {handle_update}
                menu.choice "View Appointments", -> {view}
                menu.choice "Cancel Appointment\n", -> {cancel_appointment}
                menu.choice "Write Review", -> {write_review}
                menu.choice "View Reviews", -> {patient_view_reviews}
                menu.choice "View Doctor Average Rating", -> {pt_doctors_avg}
                menu.choice "Quit", -> {quit}
            end 
        elsif @path == "Doctor"
            doctor.reload
            puts "You are logged in as a Doctor."
            menu_options = prompt.select("Please select what you would like to do.\n") do |menu|
                menu.choice "\u001b[35;1mSchedule Appointment", -> {doctor_schedules_appt} #check, create handle schedul emethod depending on patient or doctor
                menu.choice "Update Appointment", -> {doctor_handle_update}
                menu.choice "View Appointments", -> {doctor_view}
                menu.choice "Cancel Appointment\n", -> {doctor_cancel_appointment}
                menu.choice "View Your Reviews", -> {doctor_view_reviews}
                menu.choice "View Other Doctor Averages", -> {dr_doctors_avg}
                
                menu.choice "Quit", -> {quit}
            end 
        end 
    end
# Schedules an appointment for patient and if doctor already exists, chooses doctor. If doctor doesn't exist, adds doctor with their specialty
    def handle_schedule
        pt_reload_and_clear
        date = prompt.ask("\u001b[35;1m\u001b[1m What day do you want to schedule your appointment for?\u001b[0m (ex: 08-05-19)")
            puts ""
        time = prompt.ask("\u001b[35;1m\u001b[1m What time do you want to schedule your appointment for? \u001b[0m (ex: 10:00 am)")
            puts ""
        reason = prompt.ask("\u001b[35;1m\u001b[1m What is the reason for your visit?\u001b[0m")

        doc_already_listed

        Appointment.create(date: date, time: time, doctor: doctor, patient: patient, reason: reason)
        system "clear"
        patient.pt_appointments
        key_and_continue
    end
# Updates appointment attributes chosen 
    def handle_update
        pt_reload_and_clear
        if patient.appointments == [] 
            puts "\u001b[31;1m\e[5mThere are no appointments to update. Please schedule an appointment to update!\u001b[0m"
            prompt.keypress("Press any key to continue.")
            continue?
        end 
        display_appt_options
        appt_id = prompt.select("Please select an appointment: ", display_appt_options)
        appointment = Appointment.find(appt_id)
        
        choices = {Date: 1, Time: 2, Doctor: 3, Reason: 4}
        attributes = prompt.multi_select("What do you want to change about this appointment?\n", choices)
            attributes.each do |attribute|
            case attribute
            when 1
                new_date = prompt.ask("What is the new date? \u001b[1m(ex: 08-05-19)\u001b[0m\n")
                appointment.update(date: new_date) 
            when 2
                new_time = prompt.ask("What is the new time? \u001b[1m(ex: 3:15 pm)\u001b[0m\n")
                appointment.update(time: new_time)
            when 3 
                doc_already_listed
                appointment.update(doctor: doctor)
            when 4 
                new_reason = prompt.ask("What is the new reason?\n")
                appointment.update(reason: new_reason)
            end 
            system "clear"
            puts "\u001b[35;1m\u001b[4mDate:\u001b[0m #{appointment.date}"
            puts "\u001b[35;1m\u001b[4mTime:\u001b[0m #{appointment.time}"
            puts "\u001b[1m\u001b[4mPatient:\u001b[0m #{appointment.patient.name}"
            puts "\u001b[35;1m\u001b[4mDoctor:\u001b[0m #{appointment.doctor.name}"
            puts "\u001b[35;1m\u001b[4mReason:\u001b[0m #{appointment.reason}"
            line_separation      
        end 
        key_and_continue
    end
# View all appointments
    def view 
        pt_reload_and_clear
        if patient.appointments == []
            puts "\u001b[31;1mThere are no appointments to view. Please schedule an appointment to view!\u001b[0m"
            prompt.keypress("Press any key to continue.")
            continue?
       end 
        patient.pt_appointments
        key_and_continue    
    end 
# Cancels chosen appointment
    def cancel_appointment
        pt_reload_and_clear
         if patient.appointments.length < 1
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
        pt_reload_and_clear
        patient.pt_appointments 
        key_and_continue   
    end 


###########################################################################################
# DOCTOR PATHWAY

    def doctor_schedules_appt
        doc_reload_and_clear
        date = prompt.ask("\u001b[35;1m\u001b[1m What day do you want to schedule the appointment with the patient?\u001b[0m (ex: 08-05-19)\n")
        time = prompt.ask("\u001b[35;1m\u001b[1m What time do you want to schedule the appointment with the patient? \u001b[0m (ex: 10:00 am)\n")
        reason = prompt.ask("\u001b[35;1m\u001b[1m What do you need to see the patient for?\u001b[0m\n")

        pt_already_listed

        Appointment.create(date: date, time: time, doctor: doctor, patient: patient, reason: reason)
        system "clear"
        doctor.dc_appointments
        doc_key_and_continue
    end
# Updates appointment attributes chosen 
    def doctor_handle_update
        doc_reload_and_clear
        if doctor.appointments == [] 
            puts "\u001b[31;1m\e[5mThere are no appointments to update. Please schedule an appointment to update!\u001b[0m\n"
            prompt.keypress("Press any key to continue.")
            doc_continue?
        end 
        display_doc_appt_options #come back
        appt_id = prompt.select("Please select an appointment: \n", display_doc_appt_options)
        appointment = Appointment.find(appt_id)       

        choices = {Date: 1, Time: 2, Patient: 3, Reason: 4}
        attributes = prompt.multi_select("What do you want to change about this appointment?\n", choices)
            attributes.each do |attribute|
            case attribute
            when 1
                new_date = prompt.ask("What is the new date? \u001b[1m(ex: 08-05-19)\u001b[0m\n")
                appointment.update(date: new_date) 
                puts ""
            when 2
                new_time = prompt.ask("What is the new time? \u001b[1m(ex: 3:15 pm)\u001b[0m\n")
                appointment.update(time: new_time)
                puts ""
            when 3 
                system "clear"
                pt_already_listed
                appointment.update(patient: patient) 
                puts ""
            when 4 
                new_reason = prompt.ask("What is the new reason?")
                appointment.update(reason: new_reason)
                puts ""
            end 
            system "clear"
            puts "\u001b[35;1m\u001b[4mDate:\u001b[0m #{appointment.date}"
            puts "\u001b[35;1m\u001b[4mTime:\u001b[0m #{appointment.time}"
            puts "\u001b[35;1m\u001b[4mPatient:\u001b[0m #{appointment.patient.name}"
            puts "\u001b[35;1m\u001b[4mReason:\u001b[0m #{appointment.reason}"
        
            line_separation      
        end 
        doc_key_and_continue
    end
# View all appointments doctor has
    def doctor_view
        doc_reload_and_clear
        if doctor.appointments.length < 1
            system "clear"
            puts "\u001b[31;1m\e[5mThere are no appointments to view. Please schedule an appointment to view!\u001b[0m"
            doc_key_and_continue
        end 
        doctor.dc_appointments
        doc_key_and_continue
    end 
# Cancels appointment with patient
    def doctor_cancel_appointment
        doctor.reload 
        system "clear"
        if doctor.appointments == [] 
            system "clear"
            puts "\u001b[31;1m\e[5mThere are no appointments to cancel. Please schedule an appointment to cancel!\u001b[0m"
            doc_key_and_continue
        end 

        display_doc_appt_options
        appt_id = prompt.select("Which appointment would you like to cancel?", display_doc_appt_options)
        answer = prompt.yes?('Are you sure you would like to cancel this appointment with this patient?')
    
        if answer
            Appointment.destroy(appt_id)
            puts "Your appointment has been canceled"
        end
        doc_reload_and_clear
        doctor.dc_appointments 
        doc_key_and_continue     
    end 

    def quit
        exit
    end 
##################################################################################################
# REVIEW

    def write_review
        pt_reload_and_clear
        doc_already_listed

        rating = prompt.ask("\u001b[35;1m\u001b[1m What rating would you give your experience?\u001b[0m (1 - 10)")
        puts ""
        content = prompt.ask("\u001b[35;1m\u001b[1m What would you like to write about your experience? \u001b[0m ")
        puts ""

        Review.create(doctor: doctor, rating: rating, content: content, patient: patient)
        patient.see_reviews_by_pt
        prompt.keypress("Press any key to continue.")
        continue?
    end 

    def doctor_view_reviews
        if doctor.reviews == [] 
            system "clear"
            puts "\u001b[31;1m\e[5mThere are no reviews to view. Please schedule an review to view!\u001b[0m"
            doc_key_and_continue
        end 
        doctor.see_reviews_of_doc
        doc_key_and_continue
    end

    def patient_view_reviews
        if patient.reviews == [] 
            system "clear"
            puts "\u001b[31;1m\e[5mThere are no reviews to view. Please schedule an review to view!\u001b[0m"
            key_and_continue
        end 
        patient.see_reviews_by_pt
        key_and_continue
    end
    def pt_doctors_avg
        doc_already_listed
        system "clear"
        doctor.get_avg_review
        key_and_continue
    end 
    def dr_doctors_avg
        doc_already_listed
        system "clear"
        doctor.get_avg_review
        doc_key_and_continue
    end


###########################################################################################
    # HELPER METHODS FOR PATIENT

    def pt_reload_and_clear
        patient.reload
        system "clear"
    end 

    def pt_already_listed
        line_separation
        output_patient_info
        line_separation  
        prompt.select("Is your Patient already listed above?") do |m|
            m.choice 'Yes', -> {patient_in_system} 
            m.choice 'No', -> {patient_not_in_system}
        end 
        line_separation
    end 
    def key_and_continue
        prompt.keypress("Press any key to continue.")  
        continue?
    end 
    def line_separation
        puts " "
        puts "-------------------------------------"
        puts " "
    end 
    def continue?
        pt_reload_and_clear
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
        choices = %w(Cardiovascular Neurology Pulmonology Ophthalmology Orthodontal Gyneocology Family Pediatrics Dermatology)
        dr_specialty = prompt.select("Please choose a specialty for your doctor (Scroll down): ", choices)   
        @doctor.update(specialty: dr_specialty)
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

    def doc_reload_and_clear
        doctor.reload
        system "clear"
    end 
    def doc_already_listed
        line_separation
        output_doctor_specialty
        line_separation
        prompt.select("Is your doctor already listed above?") do |m|
            m.choice 'Yes', -> {doctor_in_system} 
            m.choice 'No', -> {doctor_not_in_system}
        end 
        line_separation
    end 
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
        doc_reload_and_clear
        prompt.select "What do you want to do now?" do |menu|
            menu.choice "Main Menu", -> {show_menu}
            menu.choice "Exit", -> {quit}
        end 
    end
    def doc_key_and_continue
        prompt.keypress("Press any key to continue.")  
        doc_reload_and_clear
        doc_continue?
    end 
end 