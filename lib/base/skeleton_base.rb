require 'thor/group'

module Cucumber
  module Generators
    module SkeletonBase

      DEFAULT_SHEBANG = File.join(Config::CONFIG['bindir'], Config::CONFIG['ruby_install_name'])

      def create_gemfile
        return if !options[:gemfile] || File.exist?('Gemfile')
        template 'Gemfile'    
      end    

      def configure_gemfile(m = self)                         
        return if !options[:gemfile] || !File.exist?('Gemfile')
        gsub_file 'Gemfile', /('|")gem/, "\1\ngem"
        add_gem('database_cleaner', '>=0.5.2') unless options[:skip_database]
        if framework == :rspec
          add_gem('rspec', '>=2.0.0.beta.9')
        end
        add_gem('cucumber', '>=0.7.3')
      end

      def create_cucumber_features       
        return if File.directory? 'spec'        
        empty_directory 'features'       
        inside 'features' do
          template('app_name.feature.erb', "#{app_name}.feature")        
          empty_directory 'step_definitions'
          inside 'step_definitions' do
            template('app_name_steps.erb', "#{app_name}_steps.rb")                  
          end
          empty_directory 'support'
          inside 'support' do                       
              template('env.rb.erb', 'env.rb')      
          end
        end
      end

      def create_specs
        return if File.directory? 'spec'
        empty_directory 'spec'       
        inside 'spec' do                            
          empty_directory "#{app_name}"
          template('spec_helper.rb.erb', "spec_helper.rb")      
          template('app_name/sample_spec.rb.erb', "#{app_name}/#{app_name}_spec.rb")      
        end
      end

      protected

      def add_gem(name, version = nil)
        return if has_gem? name, version
        append_file 'Gemfile' do
            s = "\ngem '#{name}'"
            s << ", '#{version}'" if version
          end        
      end

      def has_gem?(name, version = nil)
        @Gemfile ||= 'Gemfile'       
        name_exp = /gem\s*('|\")#{name}\1/
        name_version_exp =  /gem\s*('|\")#{name}\1\s*,\s*('|\")#{version}\2/
        gemfile_content = File.open(@Gemfile).read        
        return gemfile_content =~ name_version_exp if version    
        gemfile_content =~ name_exp         
      end

      def detect_current_framework
        detect_in_env([['spec', :rspec]])  || :testunit
      end

      def detect_default_framework
        # TODO need to check this - defaulting to :testunit has been moved from first_loadable
        # It's unlikely that we don't have test/unit since it comes with Ruby
        @default_framework ||= first_loadable([['rspec', :rspec]])
      end

      def embed_file(source, indent='')
        IO.read(File.join(self.class.source_root, source)).gsub(/^/, indent)
      end

      def embed_template(source, indent='')
        template = File.join(self.class.source_root, source)
        ERB.new(IO.read(template), nil, '-').result(binding).gsub(/^/, indent)
      end

      def version
        IO.read(File.join(self.class.gem_root, 'VERSION')).chomp
      end

      def first_loadable(libraries)
        require 'rubygems'

        libraries.each do |lib_name, lib_key|
          return lib_key if Gem.available?(lib_name)
        end

        nil
      end

      def detect_in_env(choices)
        return nil unless File.file?("features/support/env.rb")

        env = IO.read("features/support/env.rb")

        choices.each do |choice|
          detected = choice[1] if env =~ /#{choice[0]}/n
          return detected if detected
        end

        nil
      end
    end
  end
end