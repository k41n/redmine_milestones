require_dependency "version"
module VersionPatch
  def self.included(base) # :nodoc:

    base.class_eval do
      has_many :milestones, :order => :start_date
    end

  end
end