#!/bin/bash -e

#########################################################
# Checks out site content dependencies needed to generate the full site
#########################################################

# Check out the events repo as a direct subdir
git clone --depth=1 https://github.com/Terracotta-OSS/terracotta.org-site-events.git events

# Check out a single copy of ehcache to use below:
git clone https://github.com/ehcache/ehcache3.git __reference

# Copy each version of ehcache3 to a subdir:
# ehcache3 -> ./_ehXY
ruby run_cmd_each_javadoc_version.rb 'mkdir -p %{dir} ; (cd __reference && git archive --format=tar v%{fullversion}) | tar -C %{dir} -xf -'

# and user docs with the paths stripped out:
# ehcache3/docs/src/docs/asciidoc/user/* -> ./documentation/X.Y/
ruby run_cmd_each_javadoc_version.rb 'mkdir -p documentation/%{shortversion} ; (cd __reference && git archive --format=tar  v%{fullversion} docs/src/docs/asciidoc/user/ ) | tar -C documentation/%{shortversion} --strip-components 5 -xf -'

# clean up
rm -rf __reference
