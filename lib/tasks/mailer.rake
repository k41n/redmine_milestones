namespace :redmine do
  namespace :email do
    namespace :milestones do
      desc 'Send notifications about milestone due date approaching'
      task :notify_due_date, [:period] => :environment do |t, args|
        period = args[:period].to_i
        puts "Notifying with due date in #{period} days"
        Milestone.all.select{|x| x.planned_end_date.present? and x.planned_end_date.to_time > (period-1).days.from_now and x.planned_end_date.to_time < period.days.from_now}.each do |milestone|
          Mailer.deliver_due_date_approaches(milestone)
          Mailer.deliver_due_date_approaches(milestone, true)
        end
      end
    end
  end
end