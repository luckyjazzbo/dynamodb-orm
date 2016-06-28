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
  end
end
