require 'rake'

module Mes
  module Dynamo
    class TasksInstaller
      include Rake::DSL if defined? Rake::DSL

      def install_tasks
        Dir.glob(File.join(Mes::Dynamo::ROOT, 'lib/tasks/*.rake')).each { |r| import r }
      end
    end
  end
end

Mes::Dynamo::TasksInstaller.new.install_tasks
