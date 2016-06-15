namespace :mes_tables do
  desc 'Creates all MES models. Raises exception if any of the tables already exist'
  task :create_all do
    ::Mes::Dynamo::MODELS.each(&:create)
  end

  desc 'Drops all MES models'
  task :drop_all do
    ::Mes::Dynamo::MODELS.each(&:drop!)
  end
end
