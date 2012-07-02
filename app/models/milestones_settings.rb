class MilestonesSettings < ActiveRecord::Base
  unloadable

  def enabled?
    self.value == "true"
  end

  def disabled?
    self.value == "false"
  end
end
