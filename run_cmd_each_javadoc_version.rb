#!/usr/bin/env ruby

###############################################################################
# WARNING: This script is also used by the build system when publishing the
# website. Do not modify it without making sure publishing it still working.
#
# Current publishing build is http://jenkins.terracotta.eur.ad.sag:8080/job/websites/job/ehcache.org-site-publisher
#
# The script parses _config.yml and figure out automatically what branches of
# # ehcache should be checked out and to what local directories.
#
# You can also use this script to have a full website locally, you need the
# documentation from multiple releases. This script will get them for you.
#
# There are two ways (the command is the parameter to pass to the script)
# 1- Cloning each version with:
# ./run_cmd_each_javadoc_version.rb "git clone --branch v%{fullversion} --depth 1 https://github.com/ehcache/ehcache3.git %{dir} && ln -s $PWD/%{dir}/docs/src/docs/asciidoc/user documentation/%{shortversion}"
# 2- Doing a worktree for each version with:
# export ehcache3_root_directory=../ehcache3; ./run_cmd_each_javadoc_version.rb "sitedir=$PWD; pushd ${ehcache3_root_directory} && git worktree add \${sitedir}/%{dir} v%{fullversion} && popd && ln -s $PWD/%{dir}/docs/src/docs/asciidoc/user documentation/%{shortversion}"
#
# Both are pretty much the same. The worktree allows you to really work on the
# documentation and commit changes. The result is that the sources for each
# version will go in a directory named '$PWD/_ehXY' and
#
# git clone --branch v3.5.3 --depth 1 https://github.com/ehcache/ehcache3.git _eh35 && ln -s $PWD/_eh35/docs/src/docs/asciidoc/user documentation/3.5
#
# Runs git clone commands using the provided template
#
# Usage:
#     ./run_cmd_each_javadoc_version.rb the_command
#     - the_command can contain these tokens:
#       - fullversion: e.g 3.5.3
#       - shortversion: e.g 3.5
#       - dir: _eh35
#
###############################################################################

require 'yaml'

if ARGV[0].nil? 
  puts "Please provide a printf template for the commands to run, see source header comment for details"
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
    p "Command: #{cmd}"
    puts "Cloning Version '#{version}' (short '#{version2digit}') into '#{dir}', Running: #{cmd}"
    if !system(cmd)
      puts "Failed to clone!"
      exit(1)
    end
  end
}

