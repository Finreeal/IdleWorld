#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"

begin
  require "xcodeproj"
rescue LoadError
  warn "Missing gem: xcodeproj"
  warn "Install it with: gem install --user-install xcodeproj"
  exit 1
end

ROOT = File.expand_path("..", __dir__)
PROJECT_PATH = File.join(ROOT, "IdleWorld.xcodeproj")
APP_TARGET_NAME = "IdleWorld"
WIDGET_TARGET_NAME = "IdleWorldWidgetExtension"
APP_BUNDLE_ID = ENV.fetch("IDLEWORLD_APP_BUNDLE_ID", "com.finreeal.idleworld")
WIDGET_BUNDLE_ID = ENV.fetch("IDLEWORLD_WIDGET_BUNDLE_ID", "com.finreeal.idleworld.widget")
APP_GROUP = ENV.fetch("IDLEWORLD_APP_GROUP", "group.com.finreeal.idleworld")
DEVELOPMENT_TEAM = ENV.fetch("APPLE_TEAM_ID", "")

FileUtils.rm_rf(PROJECT_PATH)

project = Xcodeproj::Project.new(PROJECT_PATH)
project.root_object.attributes["LastSwiftUpdateCheck"] = "2600"
project.root_object.attributes["LastUpgradeCheck"] = "2600"
project.build_configuration_list.set_setting("IPHONEOS_DEPLOYMENT_TARGET", "17.0")
project.build_configuration_list.set_setting("SWIFT_VERSION", "5.0")

main_group = project.main_group
app_group = main_group.new_group("App", "App")
shared_group = main_group.new_group("Shared", "Shared")
widget_group = main_group.new_group("WidgetExtension", "WidgetExtension")

app_target = project.new_target(:application, APP_TARGET_NAME, :ios, "17.0")
widget_target = project.new_target(:app_extension, WIDGET_TARGET_NAME, :ios, "17.0")

def add_files_preserving_tree(group, target, subdir, excluded_files = [])
  Dir.glob(File.join(ROOT, subdir, "**/*.swift")).sort.each do |path|
    next if excluded_files.include?(File.basename(path))

    relative = path.sub("#{ROOT}/", "")
    path_parts = relative.split("/")
    leaf_name = path_parts.pop
    current_group = group

    path_parts.drop(1).each do |part|
      current_group = current_group[part] || current_group.new_group(part, part)
    end

    file_ref = current_group.find_file_by_path(leaf_name) || current_group.new_file(leaf_name)
    target.add_file_references([file_ref])
  end
end

def add_resource_files(group, target, subdir)
  asset_catalogs = Dir.glob(File.join(ROOT, subdir, "**/*.xcassets")).sort

  asset_catalogs.each do |catalog_path|
    relative = catalog_path.sub("#{ROOT}/", "")
    path_parts = relative.split("/")
    leaf_name = path_parts.pop
    current_group = group

    path_parts.drop(1).each do |part|
      current_group = current_group[part] || current_group.new_group(part, part)
    end

    file_ref = current_group.find_file_by_path(leaf_name) || current_group.new_file(leaf_name)
    target.resources_build_phase.add_file_reference(file_ref, true)
  end

  Dir.glob(File.join(ROOT, subdir, "**/*"), File::FNM_DOTMATCH).sort.each do |path|
    next if File.directory?(path)
    next if File.extname(path) == ".swift"
    next if path.include?(".xcassets/")
    next if path.end_with?(".xcassets")

    relative = path.sub("#{ROOT}/", "")
    path_parts = relative.split("/")
    leaf_name = path_parts.pop
    current_group = group

    path_parts.drop(1).each do |part|
      current_group = current_group[part] || current_group.new_group(part, part)
    end

    file_ref = current_group.find_file_by_path(leaf_name) || current_group.new_file(leaf_name)
    target.resources_build_phase.add_file_reference(file_ref, true)
  end
end

widget_excluded = %w[
  HealthBonusService.swift
  PostcardRenderer.swift
]

add_files_preserving_tree(app_group, app_target, "App")
add_files_preserving_tree(shared_group, app_target, "Shared")
add_files_preserving_tree(shared_group, widget_target, "Shared", widget_excluded)
add_files_preserving_tree(widget_group, widget_target, "WidgetExtension")
add_resource_files(app_group, app_target, "App")

[app_target, widget_target].each do |target|
  target.build_configurations.each do |config|
    config.build_settings["PRODUCT_BUNDLE_IDENTIFIER"] =
      target == app_target ? APP_BUNDLE_ID : WIDGET_BUNDLE_ID
    config.build_settings["SWIFT_VERSION"] = "5.0"
    config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "17.0"
    config.build_settings["CODE_SIGN_STYLE"] = "Automatic"
    config.build_settings["DEVELOPMENT_TEAM"] = DEVELOPMENT_TEAM
    config.build_settings["CURRENT_PROJECT_VERSION"] = "1"
    config.build_settings["MARKETING_VERSION"] = "1.0"
    config.build_settings["ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS"] = "YES"
  end
end

app_target.build_configurations.each do |config|
  config.build_settings["INFOPLIST_KEY_UIApplicationSceneManifest_Generation"] = "YES"
  config.build_settings["INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents"] = "YES"
  config.build_settings["INFOPLIST_KEY_UILaunchScreen_Generation"] = "YES"
  config.build_settings["INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone"] = "UIInterfaceOrientationPortrait"
  config.build_settings["INFOPLIST_KEY_CFBundleDisplayName"] = "Idle World"
  config.build_settings["TARGETED_DEVICE_FAMILY"] = "1"
  config.build_settings["GENERATE_INFOPLIST_FILE"] = "YES"
  config.build_settings["ASSETCATALOG_COMPILER_APPICON_NAME"] = "AppIcon"
  config.build_settings["INFOPLIST_KEY_NSSupportsLiveActivities"] = "YES"
  config.build_settings["INFOPLIST_KEY_NSHealthShareUsageDescription"] = "Idle World uses your step count to reward real-world movement with faster camp production."
end

widget_target.build_configurations.each do |config|
  config.build_settings["APPLICATION_EXTENSION_API_ONLY"] = "YES"
  config.build_settings["GENERATE_INFOPLIST_FILE"] = "NO"
  config.build_settings["INFOPLIST_FILE"] = "WidgetExtension/Info.plist"
  config.build_settings["SKIP_INSTALL"] = "YES"
end

shared_frameworks = %w[
  ActivityKit.framework
  SwiftUI.framework
  WidgetKit.framework
]

shared_frameworks.each do |framework|
  ref = project.frameworks_group.new_file("System/Library/Frameworks/#{framework}")
  app_target.frameworks_build_phase.add_file_reference(ref)
  widget_target.frameworks_build_phase.add_file_reference(ref)
end

healthkit_ref = project.frameworks_group.new_file("System/Library/Frameworks/HealthKit.framework")
app_target.frameworks_build_phase.add_file_reference(healthkit_ref)

entitlements_dir = File.join(ROOT, "Config")
FileUtils.mkdir_p(entitlements_dir)

app_entitlements = File.join(entitlements_dir, "IdleWorld.entitlements")
widget_entitlements = File.join(entitlements_dir, "IdleWorldWidget.entitlements")

File.write(
  app_entitlements,
  <<~PLIST
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>com.apple.security.application-groups</key>
      <array>
        <string>#{APP_GROUP}</string>
      </array>
      <key>com.apple.developer.ubiquity-kvstore-identifier</key>
      <string>$(TeamIdentifierPrefix)$(CFBundleIdentifier)</string>
    </dict>
    </plist>
  PLIST
)

File.write(
  widget_entitlements,
  <<~PLIST
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>com.apple.security.application-groups</key>
      <array>
        <string>#{APP_GROUP}</string>
      </array>
    </dict>
    </plist>
  PLIST
)

app_target.build_configurations.each do |config|
  config.build_settings["CODE_SIGN_ENTITLEMENTS"] = "Config/IdleWorld.entitlements"
end

widget_target.build_configurations.each do |config|
  config.build_settings["CODE_SIGN_ENTITLEMENTS"] = "Config/IdleWorldWidget.entitlements"
  config.build_settings["PRODUCT_NAME"] = "$(TARGET_NAME)"
end

embed_phase = app_target.new_copy_files_build_phase("Embed App Extensions")
embed_phase.symbol_dst_subfolder_spec = :plug_ins
embed_phase.add_file_reference(widget_target.product_reference, true)

widget_target.add_dependency(app_target) if false

project.save

scheme_dir = File.join(PROJECT_PATH, "xcshareddata", "xcschemes")
FileUtils.mkdir_p(scheme_dir)

scheme_path = File.join(scheme_dir, "#{APP_TARGET_NAME}.xcscheme")
scheme_xml = <<~XML
  <?xml version="1.0" encoding="UTF-8"?>
  <Scheme
     LastUpgradeVersion = "2650"
     version = "1.7">
     <BuildAction
        parallelizeBuildables = "YES"
        buildImplicitDependencies = "YES">
        <BuildActionEntries>
           <BuildActionEntry
              buildForTesting = "YES"
              buildForRunning = "YES"
              buildForProfiling = "YES"
              buildForArchiving = "YES"
              buildForAnalyzing = "YES">
              <BuildableReference
                 BuildableIdentifier = "primary"
                 BlueprintIdentifier = "#{app_target.uuid}"
                 BuildableName = "#{APP_TARGET_NAME}.app"
                 BlueprintName = "#{APP_TARGET_NAME}"
                 ReferencedContainer = "container:IdleWorld.xcodeproj">
              </BuildableReference>
           </BuildActionEntry>
        </BuildActionEntries>
     </BuildAction>
     <TestAction
        buildConfiguration = "Debug"
        selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
        selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
        shouldUseLaunchSchemeArgsEnv = "YES">
        <Testables>
        </Testables>
        <MacroExpansion>
           <BuildableReference
              BuildableIdentifier = "primary"
              BlueprintIdentifier = "#{app_target.uuid}"
              BuildableName = "#{APP_TARGET_NAME}.app"
              BlueprintName = "#{APP_TARGET_NAME}"
              ReferencedContainer = "container:IdleWorld.xcodeproj">
           </BuildableReference>
        </MacroExpansion>
     </TestAction>
     <LaunchAction
        buildConfiguration = "Debug"
        selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
        selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
        launchStyle = "0"
        useCustomWorkingDirectory = "NO"
        ignoresPersistentStateOnLaunch = "NO"
        debugDocumentVersioning = "YES"
        debugServiceExtension = "internal"
        allowLocationSimulation = "YES">
        <BuildableProductRunnable
           runnableDebuggingMode = "0">
           <BuildableReference
              BuildableIdentifier = "primary"
              BlueprintIdentifier = "#{app_target.uuid}"
              BuildableName = "#{APP_TARGET_NAME}.app"
              BlueprintName = "#{APP_TARGET_NAME}"
              ReferencedContainer = "container:IdleWorld.xcodeproj">
           </BuildableReference>
        </BuildableProductRunnable>
      <MacroExpansion>
           <BuildableReference
              BuildableIdentifier = "primary"
              BlueprintIdentifier = "#{app_target.uuid}"
              BuildableName = "#{APP_TARGET_NAME}.app"
              BlueprintName = "#{APP_TARGET_NAME}"
              ReferencedContainer = "container:IdleWorld.xcodeproj">
           </BuildableReference>
        </MacroExpansion>
     </LaunchAction>
     <ProfileAction
        buildConfiguration = "Release"
        shouldUseLaunchSchemeArgsEnv = "YES"
        savedToolIdentifier = ""
        useCustomWorkingDirectory = "NO"
        debugDocumentVersioning = "YES">
        <BuildableProductRunnable
           runnableDebuggingMode = "0">
           <BuildableReference
              BuildableIdentifier = "primary"
              BlueprintIdentifier = "#{app_target.uuid}"
              BuildableName = "#{APP_TARGET_NAME}.app"
              BlueprintName = "#{APP_TARGET_NAME}"
              ReferencedContainer = "container:IdleWorld.xcodeproj">
           </BuildableReference>
        </BuildableProductRunnable>
     </ProfileAction>
     <AnalyzeAction
        buildConfiguration = "Debug">
     </AnalyzeAction>
     <ArchiveAction
        buildConfiguration = "Release"
        revealArchiveInOrganizer = "YES">
     </ArchiveAction>
  </Scheme>
XML

File.write(scheme_path, scheme_xml)

puts "Generated #{PROJECT_PATH}"
warn "Warning: APPLE_TEAM_ID is empty. Physical-device install will require setting Signing in Xcode." if DEVELOPMENT_TEAM.empty?
