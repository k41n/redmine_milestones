require 'redmine'

VERSION_NUMBER = '1.0.0'
VERSION_STATUS = '-alpha1'

require_dependency 'milestones/hooks'
require_dependency 'milestones/helper_issues_show_detail_after_setting_hook'
require_dependency 'milestones/issue_patch'
require_dependency 'milestones/version_patch'
require_dependency 'milestones/query_patch'
require_dependency 'milestones/project_patch'
require_dependency 'milestones/projects_helper_patch'
require_dependency "milestones/gantt_patch"
require_dependency 'milestones/mailer_patch'

Redmine::Plugin.register :redmine_milestones do
  name 'Redmine Milestones plugin'
  author 'RedmineCRM'
  description 'Create, edit and manage milestones'
  version VERSION_NUMBER + '-pro' + VERSION_STATUS
  url 'http://redminecrm.com/projects/milestones'
  author_url 'http://redminecrm.com'
  requires_redmine :version_or_higher => '1.2.2'

  project_module :milestones_module do
    permission :view_milestones, {
        :milestones => [:show, :index]
    }
    permission :manage_milestones, {
        :milestones => [:show, :index, :new, :edit, :create, :update]
    }
  end

end
Issue.send(:include, IssuePatch)
Version.send(:include, VersionPatch)
Project.send(:include, ProjectPatch)
Query.send(:include, Milestones::QueryPatch)
ProjectsHelper.send(:include, ProjectsHelperPatch)
Redmine::Helpers::Gantt.send(:include, GanttPatch)
Mailer.send(:include, RedmineMilestones::MailerPatch)
