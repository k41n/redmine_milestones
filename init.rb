require 'redmine'

VERSION_NUMBER = '1.0.0'
VERSION_STATUS = '-alpha1'

require_dependency 'milestones/hooks'
require_dependency 'milestones/issue_patch'
require_dependency 'milestones/version_patch'

Redmine::Plugin.register :redmine_milestones do
  name 'Redmine Milestones plugin'
  author 'RedmineCRM'
  description 'Create, edit and manage milestones'
  version VERSION_NUMBER + '-pro' + VERSION_STATUS
  url 'http://redminecrm.com/projects/milestones'
  author_url 'http://redminecrm.com'
  requires_redmine :version_or_higher => '1.2.2'
end
Issue.send(:include, IssuePatch)
Version.send(:include, VersionPatch)