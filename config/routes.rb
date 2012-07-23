RedmineApp::Application.routes.draw do

  resources :projects do
    resources :milestones
  end

  resources :versions do
    resources :milestones do
      collection do
        get 'report_for_version'
      end
    end
  end

  resources :milestones do
    collection do
      get 'parent_project_changed'
      get 'subproject_changed'
      get 'recalculate_planned_end_date'
      get 'recalculate_start_date'
      get 'recalculate_actual_date'
      get 'issue_version_changed'
      get 'milestone_version_changed'
      get 'add_assigned_project'
      post 'update_settings'
    end
    member do
      post 'status_by'
      get 'report'
      get 'planned_end_date_changed'
      get 'start_date_changed'
    end
  end
end