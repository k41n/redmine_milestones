module RedmineMilestones
  module Hooks
    class HelperIssuesShowDetailAfterSettingHook < Redmine::Hook::ViewListener
      def helper_issues_show_detail_after_setting(context = { })
        if context[:detail].prop_key == 'milestone' or context[:detail].prop_key == 'milestone_id'
          context[:detail].reload

          d = Milestone.find_by_id(context[:detail].value)
          context[:detail].value = d.composite_description if d.present?

          d = Milestone.find_by_id(context[:detail].old_value)
          context[:detail].old_value = d.composite_description if d.present?
        end
        ''
      end
    end
  end
end