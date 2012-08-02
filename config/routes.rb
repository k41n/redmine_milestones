ActionController::Routing::Routes.draw do |map|
  map.resources :projects do |project|
    project.resources :milestones
  end

  map.resources :versions do |version|
    version.resources :milestones, :collection => {
        :report_for_version => [:get]
    }
  end

  map.resources :milestones, :collection => {
      :parent_project_changed => [:get],
      :subproject_changed => [:get],
      :recalculate_planned_end_date => [:post],
      :recalculate_start_date => [:post],
      :recalculate_actual_date => [:get],
      :issue_version_changed => [:get],
      :milestone_version_changed => [:get],
      :add_assigned_project => [:get],
      :update_settings => [:post],
  },:member => {
      :status_by => :post,
      :report => [:get],
      :planned_end_date_changed => [:get],
      :start_date_changed => [:get],
      :set_planned_to_actual => [:get],
      :confirm_delete => [:post]
  }
end