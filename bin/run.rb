require_relative '../config/environment'

cli = CarePortal.new

obj = cli.welcome

while !obj
    obj = cli.welcome
end 

if obj.class == Patient
    cli.patient = obj
else 
    cli.doctor = obj
end 



# cli.welcome
# if cli.patient_user
#     obj = cli.patient_user
#     while !obj
#         obj = cli.patient_user
#     end 
#     cli.patient = obj
# else 
#     obj = cli.doctor_user
#     while !obj
#         obj = cli.doctor_user
#     end 
#     cli.doctor = obj
    
# end



# cli.patient = patient_obj

# doctor_obj = cli.doctor_user
# while !doctor_obj
#     doctor_obj = cli.doctor_user
# end 
# cli.doctor = doctor_obj



#first version
# patient_obj = cli.welcome

# while !patient_obj
#     patient_obj = cli.welcome
# end 

# cli.patient = patient_obj

# doctor_obj = cli.doctor_user
# while !doctor_obj
#     doctor_obj = cli.doctor_user
# end 
# cli.doctor = doctor_obj

cli.show_menu

# binding.pry




puts "HELLO WORLD"
