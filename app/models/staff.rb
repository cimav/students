class Staff < ActiveRecord::Base
  ACTIVE    = 0
  INACTIVE  = 1

  STATUS = {ACTIVE    => 'Activo',
            INACTIVE  => 'Inactivo'}


  def full_name
    "#{first_name} #{last_name}" rescue ''
  end

  def full_name_by_last
    "#{last_name} #{first_name}" rescue ''
  end

  def add_extra
    self.build_contact()
    self.save(:validate => false)
  end
end
