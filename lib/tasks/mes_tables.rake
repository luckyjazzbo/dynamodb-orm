namespace :mes_tables do
  desc 'Creates all MES tables. Raises exception if any of the tables already exist'
  task :create_all do
    ::Mes::Dynamo::MODELS.each(&:create_table!)
  end

  desc 'Drops all MES tables'
  task :drop_all do
    ::Mes::Dynamo::MODELS.each(&:drop_table!)
  end
end
