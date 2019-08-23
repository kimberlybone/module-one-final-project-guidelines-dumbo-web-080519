class Appointment < ActiveRecord::Base
    belongs_to :doctor
    belongs_to :patient

    # Schedules an appointment for patient and if doctor already exists, chooses doctor. If doctor doesn't exist, adds doctor with their specialty
    def doctor_schedules_appt
        doctor.reload
        system "clear"
        date = prompt.ask("\u001b[35;1m\u001b[1m What day do you want to schedule your appointment for?\u001b[0m (ex: 08-05-19)")
        time = prompt.ask("\u001b[35;1m\u001b[1m What time do you want to schedule your appointment for? \u001b[0m (ex: 10:00 am)")
        reason = prompt.ask("\u001b[35;1m\u001b[1m What is the reason for your visit?\u001b[0m")

        line_separation
        # output_doctor_specialty
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
        continue?
    end

    def output_patient_info
        Patient.all.map{ |patient|
            puts "\u001b[35;1mDoctor:\u001b[0m #{patient.name}"
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
    # Updates appointment attributes chosen 
    def doctor_handle_update
        doctor.reload 
        system "clear"
        if doctor.appointments == [] 
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
end 