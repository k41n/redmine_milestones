ActionController::Routing::Routes.draw do |map|
  map.resources :projects do |project|
    project.resources :milestones
  end
end