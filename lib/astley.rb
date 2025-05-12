require 'yaml'
require 'erb'

module Astley
  CONFIG_PATH = File.expand_path('../../config/projects.yml', __FILE__)

  def self.load_config
    YAML.load_file(CONFIG_PATH)
  end

  def self.compile_rule(template_path, context = {})
    template = File.read(template_path)
    ERB.new(template).result_with_hash(context)
  end
end

