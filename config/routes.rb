ActionController::Routing::Routes.draw do |map|
  map.resources :projects do |project|
    project.resources :milestones
  end

  map.resources :milestones, :collection => {
      :parent_project_changed => [:get],
      :subproject_changed => [:get]
  },:member => {:status_by => :post}
end