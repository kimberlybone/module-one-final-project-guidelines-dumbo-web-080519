Doctor.destroy_all
Patient.destroy_all
Appointment.destroy_all

kim = Patient.create(name: "Kimberly Bone")
mina = Patient.create(name: "Mina Ejaz")
michelle = Patient.create(name: "Michelle Winner")
avi = Patient.create(name: "Avi Lodh")



donald = Doctor.create(name: "Dr. Donald Duck", specialty: "Cardiovascular")
lisa = Doctor.create(name: "Dr. Lisa Simpson", specialty: "Neurology" )
renee = Doctor.create(name: "Dr. Renee Cruz", specialty: "Pediatrics")
eric = Doctor.create(name: "Dr. Eric", specialty: "Orthodontal")
dan = Doctor.create(name: "Dr. Dan", specialty: "Pulmonology")

Review.create(doctor: donald, rating: 5, content: "Likes to make a lot of jokes.", patient: kim )
Review.create(doctor: lisa, rating: 9, content: "A1 doctor.", patient: mina)
Review.create(doctor: renee, rating: 10, content: "Very caring. The best doctor I've ever seen", patient: mina)

Appointment.create(date: "08-05-19", time: "3:15 pm", doctor: donald, patient: kim, reason: "My chest hurts.")
Appointment.create(date: "01-03-20", time: "9:45 am", doctor: lisa, patient: mina, reason: "Eyes are burning.")
Appointment.create(date: "06-24-19", time: "9:30 am", doctor: eric, patient: avi, reason: "My teeth are crooked.")
Appointment.create(date: "10-12-19", time: "1:14 pm", doctor: dan, patient: michelle, reason: "I can't breathe. I'm dying.")
Appointment.create(date: "04-30-21", time: "3:30 pm", doctor: renee, patient: avi, reason: "My kid has the flu.")
