module ProjectsHelperPatch
  def self.included(base) # :nodoc:

    base.class_eval do
      def project_settings_tabs
        tabs = [{:name => 'info', :action => :edit_project, :partial => 'projects/edit', :label => :label_information_plural},
                {:name => 'modules', :action => :select_project_modules, :partial => 'projects/settings/modules', :label => :label_module_plural},
                {:name => 'members', :action => :manage_members, :partial => 'projects/settings/members', :label => :label_member_plural},
                {:name => 'versions', :action => :manage_versions, :partial => 'projects/settings/versions', :label => :label_version_plural},
                {:name => 'milestones', :action => :manage_milestones, :partial => 'projects/settings/milestones', :label => :label_milestone_plural},
                {:name => 'categories', :action => :manage_categories, :partial => 'projects/settings/issue_categories', :label => :label_issue_category_plural},
                {:name => 'wiki', :action => :manage_wiki, :partial => 'projects/settings/wiki', :label => :label_wiki},
                {:name => 'repositories', :action => :manage_repository, :partial => 'projects/settings/repositories', :label => :label_repository_plural},
                {:name => 'boards', :action => :manage_boards, :partial => 'projects/settings/boards', :label => :label_board_plural},
                {:name => 'activities', :action => :manage_project_activities, :partial => 'projects/settings/activities', :label => :enumeration_activities}
        ]
        tabs.select {|tab| User.current.allowed_to?(tab[:action], @project)}
      end

      def link_to_version(version, options = {})
        active_milestone = Milestone.active_for_version(version)
        if active_milestone.present?
          active_milestone_text = "(#{t(:active_milestone)}: #{active_milestone.name})"
        else
          active_milestone_text = ""
        end
        return '' unless version && version.is_a?(Version)
        link_to_if version.visible?, "#{format_version_name(version)} #{active_milestone_text}", { :controller => 'versions', :action => 'show', :id => version }, options
      end
    end
  end
end