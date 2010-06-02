require File.join(File.dirname(__FILE__), 'base', 'skeleton_base')

module Cucumber
  class Skeleton < Thor::Group
    include Thor::Actions

    include ::Cucumber::Generators::SkeletonBase

    DEFAULT_SHEBANG = File.join(Config::CONFIG['bindir'], Config::CONFIG['ruby_install_name'])

    argument :app_name

    class_option :rspec,         :type => :boolean, :desc => "Use RSpec"
    class_option :testunit,      :type => :boolean, :desc => "Use Test::Unit"
    class_option :skip_database, :type => :boolean, :desc => "Skip modification of database.yml", :aliases => '-D', :default => true
    class_option :skip_tasks,    :type => :boolean, :desc => "Skip rake tasks", :default => true
    class_option :gemfile,       :type => :boolean, :desc => "Create Gemfile"

    attr_reader :framework

    def configure_defaults
      @framework  = framework_from_options || detect_current_framework || detect_default_framework
    end

    def generate
      create_gemfile
      configure_gemfile
      create_cucumber_features
      create_specs
    end
  
    def self.gem_root
      File.expand_path("../../../../../", __FILE__)
    end
  
    def self.source_root
      File.join(File.dirname(__FILE__), '..', 'templates', 'skeleton')
    end

    def cucumber_rails_env
      'test'
    end

    private
  
    def framework_from_options
      return :rspec if options[:rspec]
      return :testunit if options[:testunit]
      return nil
    end  
  end
end