class Doctor < ActiveRecord::Base
    has_many :appointments
    has_many :patients, through: :appointments

    # def doctor_in_system
    #     doctor_name = prompt.select("Please select your doctor", self.pluck(:name, :specialty)) 
    #     specific_drs= self.select { |doctor| doctor.name == doctor_name}
    #     @doctor = .find_by(id: self.id)
    # end 

end 