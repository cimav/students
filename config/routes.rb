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
 
  match '/servicios/:id' => 'home#services'
end
