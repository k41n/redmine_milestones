module MilestonesHelper
  def format_version_sharing(sharing)
    sharing = 'none' unless Milestone::MILESTONE_SHARINGS.include?(sharing)
    l("label_milestone_sharing_#{sharing}")
  end
end
