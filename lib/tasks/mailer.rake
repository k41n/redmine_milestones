namespace :redmine do
  namespace :email do
    namespace :milestones do
      desc 'Send notifications about milestone due date approaching'
      task :notify_due_date => :environment do
        Milestone.all.select{|x| x.planned_end_date.present? and x.planned_end_date.to_time > 6.days.from_now and x.planned_end_date.to_time < 7.days.from_now}.each do |milestone|
          Mailer.deliver_due_date_approaches(milestone)
          Mailer.deliver_due_date_approaches(milestone, true)
        end
        Milestone.all.select{|x| x.planned_end_date.present? and x.planned_end_date.to_time > 1.days.from_now and x.planned_end_date.to_time < 2.days.from_now}.each do |milestone|
          Mailer.deliver_due_date_approaches(milestone)
          Mailer.deliver_due_date_approaches(milestone, true)
        end
        Milestone.all.select{|x| x.planned_end_date.present? and x.planned_end_date.to_time > Time.now and x.planned_end_date.to_time < 1.days.from_now}.each do |milestone|
          Mailer.deliver_due_date_approaches(milestone)
          Mailer.deliver_due_date_approaches(milestone, true)
        end
      end
    end
  end
end