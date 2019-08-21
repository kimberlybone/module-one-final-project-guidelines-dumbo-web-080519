require_relative '../config/environment'




cli = CarePortal.new
patient_obj = cli.welcome

while !patient_obj
    patient_obj = cli.welcome
end 

cli.patient = patient_obj
cli.show_menu

# binding.pry




puts "HELLO WORLD"
