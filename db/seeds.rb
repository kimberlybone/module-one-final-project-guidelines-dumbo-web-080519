Doctor.destroy_all
Patient.destroy_all
Appointment.destroy_all

kim = Patient.create(name: "Kimberly Bone")
mina = Patient.create(name: "Mina Ejaz")

donald = Doctor.create(name: "Dr. Donald Duck", specialty: "Cardiovascular")
lisa = Doctor.create(name: "Dr. Lisa Simpson", specialty: "Neurology")

Appointment.create(date: "08-05-19", time: "3:15 pm", doctor: donald, patient: kim, reason: "My chest hurts.")
Appointment.create(date: "06-24-19", time: "9:30 am", doctor: lisa, patient: mina, reason: "Eyes are burning.")
