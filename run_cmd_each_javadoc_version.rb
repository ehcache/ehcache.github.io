#!/usr/bin/env ruby

###############################################################################
# Big hack to parse _config.yml and figure out automatically what branches of
# ehcache should be checked out and to what local directories.
#
# Runs git clone commands using the provided template
#
# Usage:
#     ./run_cmd_each_javadoc_version.rb 'git clone --branch v%s --depth 1 https://bla.bla %s'
#     # tokens are branch and dir
#
###############################################################################


require 'yaml'

if ARGV[0].nil? 
  puts "Please provide a printf template for the commands to run, see source for details"
  exit 1
end

file_content= YAML.load_file("_config.yml")

#for all versions that mention the checkout dir
file_content['defaults'].find_all{|item| item['values'] && item['values']['ehc_checkout_dir_var']}.each{|item|

  # Look for this variable name in the asciidoctor attributes
  varname = item['values']['ehc_checkout_dir_var']

  # Asciidoctor attributes are an array of NVP's as strings
  dir = file_content['asciidoctor']['attributes'].find{|element| element.start_with?("#{varname}=")}.gsub(/.*=\/?/, '')

  version = item['values']['ehc_javadoc_version']
  version2digit = version.split('.')[0..1].join('.')


  # p "Found #{dir}, #{version}"

  if version && dir
    cmd = ARGV[0] % {:fullversion => version, :shortversion => version2digit, :dir => dir}
    puts "Cloning Version '#{version}' (short '#{version2digit}') into '#{dir}', Running: #{cmd}"
    if !system(cmd)
      puts "Failed to clone!"
      exit(1)
    end
  end
}

