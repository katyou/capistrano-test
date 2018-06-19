# config valid for current version and patch releases of Capistrano
lock "~> 3.11.0"

set :application, "capistrano-test"
set :repo_url, "git@github.com:katyou/capistrano-test.git"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/var/www/capistrano-test"
set :user, 'deploy'

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
set :pty, true

set :puma_threds,  [4, 16]
set :puma_workers, 0
set :rbenv_ruby, '2.4.1'
set :rbenv_custom_path, '/usr/local/rbenv'

# Default value for :linked_files is []
# append :linked_files, "config/database.yml"

set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log,  "#{release_path}/log/puma.access.log"
set :ssh_options,     {
  forward_agent: true,
  keys: %w(~/.ssh/ijgn-commmon.pem),
  auth_methods: %w(publickey),
  port: 22
}
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true  # Change to false when not using ActiveRecord
# Default value for linked_dirs is []
append :linked_dirs, "log ", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"


namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end
  before :start, :make_dirs
end

namespace :deploy do
  desc "Make sure local git is in sync with remote."
  task :confirm do
    on roles(:app) do
      puts "This stage is '#{fetch(:stage)}'. Deploying branch is '#{fetch(:branch)}'."
      puts 'Are you sure? [y/n]'
      ask :answer, 'n'
      if fetch(:answer) != 'y'
        puts 'deploy stopped'
        exit
      end
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      Rake::Task["puma:restart"].reenable
      invoke 'puma:restart'
    end
  end

  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      # before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  before :starting,     :confirm
  # after  :finishing,    :compile_assets
  # after  :finishing,    :cleanup

end


# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
