require 'rake'

module DynamodbOrm
  class TasksInstaller
    include Rake::DSL if defined? Rake::DSL

    def install_tasks
      Dir.glob(File.join(DynamodbOrm::ROOT, 'lib/tasks/*.rake')).each { |r| import r }
    end
  end
end

DynamodbOrm::TasksInstaller.new.install_tasks
