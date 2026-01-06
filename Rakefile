# frozen_string_literal: true

require 'cocoapods'
require 'fileutils'
require 'pathname'
require 'shellwords'
require 'xcodeproj'

module Release
  extend self

  FRAMEWORKS = %w[Lynx LynxBase LynxServiceAPI PrimJS].freeze
  ROOT = File.expand_path(__dir__)
  BUILD_SCRIPT = File.join(ROOT, 'build_xcframeworks.sh')
  OUTPUT_DIR = File.join(ROOT, 'output')
  XCFRAMEWORK_DIR = File.join(OUTPUT_DIR, 'xcframeworks')
  ARTIFACT_DIR = File.join(OUTPUT_DIR, 'release', 'artifacts')

  def frameworks
    FRAMEWORKS
  end

  def ensure_dirs!
    FileUtils.mkdir_p(ARTIFACT_DIR)
  end

  def build_script
    BUILD_SCRIPT
  end

  def ensure_framework!(name)
    path = File.join(XCFRAMEWORK_DIR, "#{name}.xcframework")
    raise "XCFramework not found: #{path}" unless Dir.exist?(path)

    path
  end

  def ensure_xcframework_dir!
    raise "XCFramework directory not found: #{XCFRAMEWORK_DIR}" unless Dir.exist?(XCFRAMEWORK_DIR)
  end

  def artifact_zip_path(name)
    File.join(ARTIFACT_DIR, "#{name}.xcframework.zip")
  end

  def run!(command)
    puts "→ #{command}"
    success = system(command)
    raise "Command failed: #{command}" unless success
  end

  def zip_framework(name)
    ensure_dirs!
    source = ensure_framework!(name)
    destination = artifact_zip_path(name)
    FileUtils.rm_f(destination)
    run!("ditto -c -k --sequesterRsrc --keepParent '#{source}' '#{destination}'")
    destination
  end

  def print_artifact_summary!
    puts 'Prepared XCFramework artifacts:'
    frameworks.each do |name|
      puts "- #{name}: #{artifact_zip_path(name)}"
    end
  end
end

module ProjectSetup
  extend self

  PROJECT_NAME = 'LynxPrebuild'
  PROJECT_PATH = File.join(Release::ROOT, "#{PROJECT_NAME}.xcodeproj")

  def project_exists?
    Dir.exist?(PROJECT_PATH)
  end

  def create_project!
    if project_exists?
      puts "Xcode project already exists at #{PROJECT_PATH}"
      return PROJECT_PATH
    end

    project = Xcodeproj::Project.new(PROJECT_PATH)
    project.new_target(:application, PROJECT_NAME, :ios)
    project.save
    puts "Created Xcode project at #{PROJECT_PATH}"
    PROJECT_PATH
  end

  def install_pods!
    Release.run!('bundle exec pod install')
  end
end

namespace :setup do
  desc 'Create LynxPrebuild.xcodeproj'
  task :project do
    ProjectSetup.create_project!
  end

  desc 'Install CocoaPods dependencies'
  task pods: :project do
    ProjectSetup.install_pods!
  end

  task all: :pods
end

namespace :build do
  desc 'Build XCFrameworks using Pods-LynxPrebuild scheme'
  task xcframeworks: 'setup:pods' do
    Release.run!("bash '#{Release.build_script}'")
  end
end

namespace :package do
  desc 'Extract required XCFrameworks and compress them into zip files'
  task zip: 'build:xcframeworks' do
    Release.frameworks.each { |name| Release.zip_framework(name) }
  end
end

namespace :release do
  desc 'Prepare XCFramework zip files for distribution'
  task prepare: 'package:zip' do
    Release.print_artifact_summary!
  end
end

task default: 'release:prepare'
