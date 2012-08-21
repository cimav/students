class Student < ActiveRecord::Base
  belongs_to :program
  belongs_to :campus

  belongs_to :state
  belongs_to :country

  has_one :contact, :as => :attachable
  accepts_nested_attributes_for :contact

  has_one :thesis
  accepts_nested_attributes_for :thesis

  has_many :scholarship
  accepts_nested_attributes_for :scholarship

  has_many :advance
  accepts_nested_attributes_for :advance

  has_many :student_file
  accepts_nested_attributes_for :student_file

  has_many :term_students
  accepts_nested_attributes_for :term_students

  mount_uploader :image, StudentImageUploader

  DELETED   = 0
  ACTIVE    = 1
  GRADUATED = 2
  INACTIVE  = 3
  UNREGISTERED = 4
  FINISH = 5

  STATUS = {
            DELETED   => 'Registro Eliminado',
            ACTIVE    => 'Activo',
            FINISH => 'Egresado no graduado',
            GRADUATED => 'Graduado',
            INACTIVE  => 'Baja temporal',
            UNREGISTERED  => 'Baja definitiva'
           }

  def status_type
    STATUS[status]
  end
 
  def full_name
    "#{first_name} #{last_name}" rescue ''
  end

  def full_name_by_last
    "#{last_name} #{first_name}" rescue ''
  end

  def full_name_with_card
    "#{card}: #{first_name} #{last_name}" rescue ''
  end



end
