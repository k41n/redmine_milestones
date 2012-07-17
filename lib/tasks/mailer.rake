namespace :redmine do
  namespace :email do
    namespace :milestones do
      desc 'Send notifications about milestone due date approaching'
      task :notify_due_date, [:period] => :environment do |t, args|
        period = args[:period].to_i
        Milestone.all.select{|x| x.planned_end_date.present? and x.planned_end_date.to_time > (period-1).days.from_now and x.planned_end_date.to_time < period.days.from_now}.each do |milestone|
          puts "Notifying about #{milestone.name}"
          Mailer.deliver_due_date_approaches(milestone, period)
          Mailer.deliver_due_date_approaches(milestone, period, true)
        end
      end
    end
  end
end