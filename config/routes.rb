Students::Application.routes.draw do
  root :to => 'home#index'
  match 'home/index' => 'home#index'

  match '/auth/:provider/callback' => 'sessions#create'
  match '/auth/failure' => 'sessions#failure'
  match "/logout" => 'sessions#destroy'
  match '/login' => 'login#index'

  match '/kardex/:id' => 'students#kardex'
  match '/calificaciones/:id/:term_id' => 'students#term_grades'
  
  match '/horarios/:id/:term_id' => 'students#schedule_table'
  match '/avances' => 'home#student_advances_files'
  
  match '/avances/borrar/:id' => 'student_advances_file#destroy'
  match '/avances/archivo' => 'student_advances_file#index'
  match '/avances/subir_archivo' => 'student_advances_file#upload_file'
  match '/avances/:id/file' => 'student_advances_file#file'
  
  match '/inscripciones/:origin' => 'students#enrollment'
 
  match '/servicios/:id' => 'home#services'

  resources :student_advances_file_messages, :path=>'/avances/mensajes'
end
