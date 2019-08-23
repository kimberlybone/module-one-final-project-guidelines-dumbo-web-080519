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
cli.show_menu