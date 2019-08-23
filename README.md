CarePortal 
@author : Kimberly Bone , Zermina Ejaz

 
Portal for Patients and Doctors to be able to view, update, cancel, and schedule an appointment. 

A Patient User can create reviews on doctors. On the other hand, a Doctor will only be able to view their own reviews with an average rating, as well as other doctor's average rating. Both Users will be able to view their own reviews and the average rating of other doctors.
 
Menu features come from TTY::Prompt

“TTY::Prompt provides independent prompt component for TTY toolkit.”


Features
- Log In as an Existing Patient/Doctor or Create an Account
- Schedule a new appointment
- Update an existing appointment
- Cancel an existing appointment
- View doctor/patient’s appointments
- Create Reviews (Patient)
- View Reviews of/from self (Doctor/Patient)
- View Other Doctor Average Rating (Doctor/Patient)


-- Schedule an Appointment
Prompts the user to enter the following details in order to create an Appointment
Date
Time
Doctor/Patient (depending on User Type [Patient or Doctor] )
Reason for seeing Patient/Doctor
 
-- Update an Appointment
Shows a list of the patient/doctor’s appointment dates and prompts the user to select the date they want to go into
Prompts the user to select an appointment on that date
Prompts the user to select the attributes of an appointment that needs to be updated and asks for the information 
Shows the updated appointment

-- View an Appointment
Shows all the user’s appointments by date, time, patient/doctor(+specialty), reason
 
 
-- Cancel an Appointment
Shows all the user’s appointments by date, time, patient/doctor(+specialty), reason
Prompts the user to select an appointment to cancel
Confirms the decision
Cancels the appointment
Displays “Your appointment has been cancelled” when successfully cancelled
Displays the remaining appointments 
 

---------------------------------

Reviews
- rating (1-10)
- doctor
- content/info
- author (patient)

-- Create a Review (Patient)
A Patient User can create reviews

-- View Reviews (Patient/Doctor)
A Doctor can view their average rating and reviews of themself , and a Patient can view reviews they have written.

-- View Other Doctor Average Rating (Patient/ Doctor)
A Patient and a Doctor can select a doctor and view their average rating.


 
 
 
 
 
 
