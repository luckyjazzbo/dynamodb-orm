namespace :mes do
  namespace :dynamo do
    desc 'Creates all MES tables. Raises exception if any of the tables already exist'
    task :create_tables do
      ::Mes::Dynamo.models.each(&:create_table!)
    end

    desc 'Drops all MES tables'
    task :drop_tables do
      ::Mes::Dynamo.models.each(&:drop_table!)
    end

    desc 'Updates all MES tables. Creates tables, which do not exist yet'
    task :update_tables do
      ::Mes::Dynamo.models.each(&:ensure_table!)
    end

    desc 'Creates MES table. Raises exception if table already exist'
    task :create_table, :name do |_, args|
      model = "::Mes::#{args[:name].classify}".constantize
      model.create_table!
    end

    desc 'Drops MES table'
    task :drop_table, :name do |_, args|
      model = "::Mes::#{args[:name].classify}".constantize
      model.drop_table!
    end

    desc 'Update MES table. Creates table, if it does not exist yet'
    task :update_table, :name do |_, args|
      model = "::Mes::#{args[:name].classify}".constantize
      model.ensure_table!
    end

    desc 'Update MES table with index recreating. Creates table, if it does not exist yet.' \
         'Indices will be recreated only if necessary'
    task :force_update_table, :name do |_, args|
      model = "::Mes::#{args[:name].classify}".constantize
      model.update_table!(force: true)
    end
  end
end
