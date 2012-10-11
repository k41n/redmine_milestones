set :application, "Redmine Milestones"
set :repository,  "git://github.com/k41n/redmine_milestones.git"
set :deploy_to, "/var/data/saas/test/redmine/tmp/git-cache/redmine_milestones"

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :user, "www-data"
set :use_sudo, false
set :files_owner, "www-data"
set :files_group, "www-data"


role :web, "redminecrm.com"                          # Your HTTP server, Apache/etc
role :app, "redminecrm.com"                          # This may be the same as your `Web` server
role :db,  "redminecrm.com", :primary => true # This is where Rails migrations will run

after "deploy", :setup_symlinks
after "deploy", "deploy:migrate"

task :setup_symlinks, :roles => :app do
  run "ln -nfs #{release_path} /var/data/saas/test/redmine/vendor/plugins/redmine_milestones"
end

namespace :deploy do
   task :start do ; end
   task :stop do ; end
   task :restart, :roles => :app, :except => { :no_release => true } do
     run "#{try_sudo} touch /var/data/saas/test/redmine/tmp/restart.txt"
   end

   task :migrate do
     rake = fetch(:rake, "rake")
     rails_env = fetch(:rails_env, "production")
     migrate_env = fetch(:migrate_env, "")
     migrate_target = fetch(:migrate_target, :latest)

     directory = case migrate_target.to_sym
                   when :current then current_path
                   when :latest  then current_release
                   else raise ArgumentError, "unknown migration target #{migrate_target.inspect}"
                 end
     #run "cd #{directory}; bundle update"
     run "cd /var/data/saas/test/redmine; #{rake} RAILS_ENV=#{rails_env} #{migrate_env}  bundle exec db:migrate:plugin NAME=redmine_milestones --trace"
   end

end