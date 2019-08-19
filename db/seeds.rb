Doctor.destroy_all
Patient.destroy_all
Appointment.destroy_all

kim = Patient.create(name: "Kimberly Bone")
mina = Patient.create(name: "Mina Ejaz")

donald = Doctor.create(name: "Dr. Donald", specialty: "Cardiovascular")
lisa = Doctor.create(name: "Dr. Lisa", specialty: "Neurology")

Appointment.create(date: "8/5", time: "3:15", doctor: donald, patient: kim, reason: "My chest hurts.")
Appointment.create(date: "6/24", time: "9:30", doctor: lisa, patient: mina, reason: "Eyes are burning.")
