require 'rake'
require 'json'
require 'byebug'

def set(key, value) 
  file = File.open("LayerConfiguration.json", "rb")
  json_string = file.read
  json = JSON.parse(json_string)[0]
  if value == nil
    json.delete(key)
  else
    json[key] = value
  end
  json_string = JSON.pretty_generate([json])
  File.open('LayerConfiguration.json', 'w') { |file| file.write(json_string) }
  puts(json_string)
end

namespace :init do

  desc "Initialize the project for development including Layer and/or LayerUI as development pods from their submodules. Examples:" +
  "\n\n\tuse the Atlas submodule as a development pod:" +
  "\n\n\t\trake init:submodules ui=1" +
  "\n\n\tuse both Layer and LayerUI submodules as development pods, by providing a location for LayerKit:" +
  "\n\n\t\trake init:submodules ui=1 core=/path/to/.../LayerKit"
  task :submodules do
    layer_core_location = ENV['core']
    core_submodule_flag = ''

    layer_ui_submodule = ENV['ui'] == '1'
    ui_submodule_flag = ''

    if File.directory?(layer_core_location) then
      puts green("Using LayerKit repository at #{layer_core_location} as a development pod.")
      core_submodule_flag = "LAYER_USE_CORE_SDK_LOCATION=#{layer_core_location} "
    else
      puts green('Using public LayerKit CocoaPod release.')
    end

    if layer_ui_submodule then
      puts green('Using Atlas submodule as a development pod.')
      system 'git submodule update --init Libraries/Atlas'
      ui_submodule_flag = 'LAYER_USE_UI_SDK_SUBMODULE=1 '
    else
      puts green('Using public Atlas CocoaPod release.')
    end

    pod_update = "#{core_submodule_flag}#{ui_submodule_flag}rbenv exec pod update"
    puts green(pod_update)
    system pod_update

    show_config_instructions
  end
  
end

desc "Initialize the project for the first time"
task :init do
  pod_update = "rbenv exec pod update"
  puts green(pod_update)
  system pod_update
 
  show_config_instructions
end

def show_config_instructions
  puts green("Configure your App ID") 
  puts "To set your app ID please run:"
  puts
  puts "\trake configure:set_app_id[\"{YOUR_APP_ID}\"]"
  puts
  puts "by replacing {YOUR_APP_ID} with your Layer App ID."
  puts
  puts grey("Done Initializing your project")
end

desc "Layer configuration"
namespace :configure do
  desc "Set a LayerConfiguration.json Key"
  task :set, [:key, :value] do |t, args|
    key = args[:key] 
    value = args[:value]
    set(key, value)  
  end  

  desc "Set the Layer app_id"
  task :set_app_id, [:app_id] do |t, args|
    set("app_id", args[:app_id])
  end

  desc "Set the Layer Idenity"
    task :set_identity_provider_url, [:identity_provider_url] do |t, args|
    set("identity_provider_url", args[:identity_provider_url])
  end

  desc "Clear the LayerConfiguration.json"
  task :clear do
    File.open('LayerConfiguration.json', 'w') { |file| file.write("{\n}") }
    puts("Done")
  end
end

def green(string)
 "\033[1;32m* #{string}\033[0m"
end

def yellow(string)
 "\033[1;33m>> #{string}\033[0m"
end

def grey(string)
 "\033[0;37m#{string}\033[0m"
end
