module Milestones
  class Hooks < Redmine::Hook::ViewListener
    #render_on :view_versions_show_bottom, :partial => 'hooks/milestones/view_versions_show_bottom'
    render_on :view_projects_roadmap_version_bottom, :partial => 'hooks/milestones/view_projects_roadmap_version_bottom'
    render_on :view_issues_form_details_bottom, :partial => 'hooks/milestones/view_issues_form_details_bottom'
    render_on :view_issues_show_details_bottom, :partial => 'hooks/milestones/view_issues_show_details_bottom'
    render_on :view_issues_context_menu_start, :partial => 'hooks/milestones/view_issues_context_menu_start'
  end
end