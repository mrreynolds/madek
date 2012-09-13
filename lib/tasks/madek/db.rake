namespace :madek do
  namespace :db  do

    desc "Transfer the data from on SOURCE env TARGET env (env is anything defined in config/database.yml)"
    task :transfer => :environment do
      DBHelper.transfer Constants::ALL_TABLES, ENV['SOURCE'], ENV['TARGET']
      DBHelper.reset_autoinc_sequences Constants::ALL_TABLES
    end

    desc "Reset the autoinc values" 
    task :reset_auto_inc => :environment do
      DBHelper.reset_autoinc_sequences Constants::ALL_TABLES
    end

    desc "Dump the database from whatever DB to YAML"
    task :dump_to_yaml => :environment do
      data_hash = DBHelper.create_hash Constants::ALL_TABLES
      file_path = Rails.root.join "tmp", "#{DBHelper.base_file_name}.yml"
      File.open(file_path, "w"){|f| f.write data_hash.to_yaml } 
      puts "the file has been saved to #{file_path}"
    end

    desc "Restore the DB from YAML" 
    task :restore_from_yaml => :environment do
      if file_name= ENV['FILE']
        h = YAML.load File.read file_name
        DBHelper.import_hash h, Constants::ALL_TABLES
      else
        raise "missing FILE env varialbe"
      end
    end

    desc "Dump the database in the native adapter format"
    task :dump => :environment do
      DBHelper.dump_native config: Rails.configuration.database_configuration[Rails.env]
    end

    desc "Restore the database from native adapter format" 
    task :restore => :environment do
      puts "dropping the db" 
      Rake::Task["db:drop"].invoke
      puts "creating the db"  
      Rake::Task["db:create"].invoke
      DBHelper.restore_native ENV['FILE'], config: Rails.configuration.database_configuration[Rails.env]
    end

    desc "Restore Personas DB (and migrate to the maximal migration version if necessary)"
    task :restore_personas  => :environment do
      PersonasDBHelper.clone_persona_to_test_db
    end

  end
end
