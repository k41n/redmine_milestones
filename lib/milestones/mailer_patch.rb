require 'dispatcher'

module RedmineMilestones
  module MailerPatch
    module ClassMethods
    end

    module InstanceMethods
      def due_date_approaches(milestone, period, owner = false)
        if owner
          recipients milestone.user.mail
        else
          recipients milestone.observer_recipients
        end

        subject "Milestone`s [#{milestone.project.name}] - #{milestone.version.name + ' - ' if milestone.version} #{milestone.name} alert (due date in #{period} days)"


        body :milestone => milestone,
             :owner => owner
        render_multipart('due_date', body)
      end
    end

    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
      receiver.class_eval do
        unloadable
        self.instance_variable_get("@inheritable_attributes")[:view_paths] << RAILS_ROOT + "/vendor/plugins/redmine_milestones/app/views"
      end
    end

  end

end

Dispatcher.to_prepare do

  unless Mailer.included_modules.include?(RedmineMilestones::MailerPatch)
    Mailer.send(:include, RedmineMIlestones::MailerPatch)
  end

end

