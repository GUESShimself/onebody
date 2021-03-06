namespace :onebody do

  namespace :export do

    desc 'Export the SQL for a single site (pass SITE_ID and OUT_FILE arguments)'
    task :site => :environment do
      db = YAML::load_file(Rails.root.join('config/database.yml'))['production']
      if ENV['SITE_ID'] and ENV['OUT_FILE']
        db_and_credentials = "-u#{db['username']} -p#{db['password']} #{db['database']}"
        `mysqldump \\
          --single-transaction \\
          --ignore-table=#{db['database']}.people_verses \\
          --ignore-table=#{db['database']}.admins_reports \\
          --ignore-table=#{db['database']}.schema_migrations \\
          --ignore-table=#{db['database']}.sessions \\
          --ignore-table=#{db['database']}.signin_failures \\
          --ignore-table=#{db['database']}.sites \\
          --ignore-table=#{db['database']}.taggings \\
          --ignore-table=#{db['database']}.processed_messages \\
          -w"site_id = #{ENV['SITE_ID']}" \\
          #{db_and_credentials} \\
          > #{ENV['OUT_FILE']}`
        `mysqldump \\
          --single-transaction \\
          -w"person_id in (select id from people where site_id=#{ENV['SITE_ID']})" \\
          #{db_and_credentials} people_verses \\
          >> #{ENV['OUT_FILE']}`
        `mysqldump \\
          --single-transaction \\
          -w"tag_id in (select id from tags where site_id=#{ENV['SITE_ID']})" \\
          #{db_and_credentials} taggings \\
          >> #{ENV['OUT_FILE']}`
        `mysqldump \\
          --single-transaction \\
          -w"admin_id in (select id from admins where site_id=#{ENV['SITE_ID']})" \\
          #{db_and_credentials} admins_reports \\
          >> #{ENV['OUT_FILE']}`
        `mysqldump \\
          --single-transaction \\
          -w"id=#{ENV['SITE_ID']}" \\
          #{db_and_credentials} sites \\
          >> #{ENV['OUT_FILE']}`
      else
        puts 'Must specify SITE_ID and OUT_FILE arguments'
      end
    end

    namespace :people do

      desc 'Export OneBody people data as XML file (pass FILE argument)'
      task :xml => :environment do
        Site.current = site = ENV['SITE'] ? Site.where(name: ENV["SITE"]).first : Site.find(1)
        if ENV['FILE']
          people = Person.all(:order => 'last_name, first_name, suffix')
          File.open(ENV['FILE'], 'w') do |file|
            file.write people.to_xml(:except => %w(feed_code encrypted_password salt api_key site_id), :include => [:groups, :family])
          end
        else
          puts 'You must specify the output file path, e.g. FILE=people.xml'
        end
      end

    end

    desc 'Export OneBody photos for particular SITE_ID, save to OUT_PATH'
    task :photos => :environment do
      require 'fileutils'
      Site.current = site = Site.find(ENV['SITE_ID'])
      [Family, Group, Person, Picture].each do |model|
        plural = model.name.pluralize.downcase
        out_path = File.join(ENV['OUT_PATH'], plural, 'photos')
        FileUtils.mkdir_p(out_path)
        model.where('photo_file_name is not null').order(:id).find_each do |record|
          puts "#{model.name} #{record.id}"
          system("cp -r public/system/production/#{plural}/photos/#{record.id} #{out_path}/#{record.id}")
        end
      end
      out_path = File.join(ENV['OUT_PATH'], 'attachments', 'files')
      FileUtils.mkdir_p(out_path)
      Attachment.where('file_file_name is not null').order(:id).find_each do |record|
        puts "Attachment #{record.id}"
        system("cp -r public/system/production/attachments/files/#{record.id} #{out_path}/#{record.id}")
      end
      out_path = File.join(ENV['OUT_PATH'], 'sites', 'logos')
      FileUtils.mkdir_p(out_path)
      if Site.current.logo.exists?
        system("cp -r public/system/production/sites/logos/#{Site.current.id} #{out_path}/#{Site.current.id}")
      end
    end

  end

end
