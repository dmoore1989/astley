# frozen_string_literal: true

module Astley
  class RuleCompiler
    CONFIG_PATH = File.expand_path('../../../config/projects.yml', __FILE__)
    RULES_DIR = File.expand_path('../../../rules', __FILE__)

    def self.compile(project, agentic)
      require 'yaml'
      require 'erb'
      require 'fileutils'

      unless File.exist?(CONFIG_PATH)
        raise "Config file not found: #{CONFIG_PATH}"
      end
      config = YAML.load_file(CONFIG_PATH)
      project_config = config['projects'][project] rescue nil
      raise "Project not found: #{project}" unless project_config
      rules = project_config['rules'] || []
      raise "No rules defined for project: #{project}" if rules.empty?

      case agentic.downcase
      when 'cursor'
        project_rules_dir = File.join(project_config['path'], 'rules')
        FileUtils.mkdir_p(project_rules_dir)
        rules.each do |rule_file|
          template_path = File.join(RULES_DIR, rule_file)
          unless File.exist?(template_path)
            warn "Template not found: #{template_path}"
            next
          end
          template = File.read(template_path)
          erb = ERB.new(template)
          compiled = erb.result_with_hash(project: project)
          output_path = File.join(project_rules_dir, File.basename(rule_file, '.erb'))
          File.write(output_path, compiled)
          puts "Compiled #{rule_file} -> #{output_path}"
        end
      when 'avante', 'avante.nvim'
        modes = %w[agentic planning editing suggesting]
        project_dir = project_config['path']
        modes.each do |mode|
          # Find all rules for this mode (e.g., *_agentic.erb)
          mode_rule_files = rules.select { |r| r.include?(mode) }
          next if mode_rule_files.empty?
          compiled_rules = mode_rule_files.map do |rule_file|
            template_path = File.join(RULES_DIR, rule_file)
            unless File.exist?(template_path)
              warn "Template not found: #{template_path}"
              next
            end
            template = File.read(template_path)
            erb = ERB.new(template)
            erb.result_with_hash(project: project)
          end.compact.join("\n")
          output_filename = "#{project}.#{mode}.avanterules"
          output_path = File.join(project_dir, output_filename)
          File.write(output_path, compiled_rules)
          puts "Compiled Avante rules for #{mode} -> #{output_path}"
        end
      else
        raise "Agentic system not supported: #{agentic}"
      end
    end
  end
end

