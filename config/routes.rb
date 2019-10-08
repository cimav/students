Students::Application.routes.draw do
  root :to => 'home#index'
  match 'home/index' => 'home#index'

  match '/auth/:provider/callback' => 'sessions#create'
  match '/auth/failure' => 'sessions#failure'
  match "/logout" => 'sessions#destroy'
  match '/login' => 'login#index'

  match '/kardex/:id' => 'students#kardex'
  match '/calificaciones/:id/:term_id' => 'students#term_grades'
  match '/calificaciones' => 'students#term_grades'

  match '/horarios/:id/:term_id' => 'students#schedule_table'
  match '/avances' => 'home#student_advances_files'
  
  match '/avances/borrar/:id' => 'student_advances_file#destroy'
  match '/avances/archivo' => 'student_advances_file#index'
  match '/avances/subir_archivo' => 'student_advances_file#upload_file'
  match '/avances/:id/file' => 'student_advances_file#file'
  
  match '/inscripciones/cimav'              => 'students#enrollment'
  match '/inscripcion/cimav'                => 'students#enrollment'
  match '/inscripcion/alumno/:tcs_id'       => 'students#endrollment'
  match '/inscripcion/folio/:folio'         => 'students#check_folio'
  match '/inscripcion/upload_file_register' => 'students#upload_file_register'
  match '/inscripcion/file/:id'             => 'enrollment_files#download'
  match '/inscripcion/destroy_file/:id'     => 'enrollment_files#applicant_destroy'

 
  match '/servicios' => 'home#services'

  match '/alumnos/inscripcion/materias/:id' => 'students#enrollment_courses'
  match '/alumnos/inscripcion/' => 'students#assign_courses'
  match '/alumnos/protocolo/:id/:staff_id' => 'students#get_protocol'
  match '/alumnos/seminario/:id/:staff_id' => 'students#get_protocol'

  match '/evaluacion/:tcs_id'   => 'teacher_evaluations#new'

  resources :student_advances_file_messages, :path=>'/avances/mensajes'
  scope(:path_names => { :new => "nuevo", :edit => "editar" }) do
    resources :teacher_evaluations,:path=>"evaluacion"
  end
  
end
