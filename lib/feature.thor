require File.join(File.dirname(__FILE__), 'base', 'named_arg')
require File.join(File.dirname(__FILE__), 'base', 'feature_base')

module Cucumber
  class Feature < Thor::Group
    include Thor::Actions
    
    include ::Cucumber::Generators::FeatureBase
    
    argument :name
    argument :fields, :optional => true, :type => :array, :banner => "[field:type, field:type]"

    attr_reader :named_args
  
    def parse_fields
      @named_args = @fields.nil? ? [] : @fields.map { |arg| NamedArg.new(arg) }
    end    

    def generate
      create_directory
      create_feature_file
      create_steps_file
      create_support_file
    end
  
    def self.banner
      "#{$0} cucumber:feature ModelName [field:type, field:type]"
    end
  
    def self.gem_root
      File.expand_path("../../../../../", __FILE__)
    end
  
    def self.source_root
      File.join(File.dirname(__FILE__), '..', 'templates', 'feature')
    end
  
  end
end