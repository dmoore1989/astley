# frozen_string_literal: true

module Astley
  class ProjectLister
    CONFIG_PATH = File.expand_path('../../../config/projects.yml', __FILE__)

    def self.list
      require 'yaml'
      unless File.exist?(CONFIG_PATH)
        raise "Config file not found: #{CONFIG_PATH}"
      end
      config = YAML.load_file(CONFIG_PATH)
      config['projects']&.keys || []
    end
  end
end

