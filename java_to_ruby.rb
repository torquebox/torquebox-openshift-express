#! /usr/bin/env ruby

# This script takes the Java application template created from the
# JBoss AS7 cartridge on OpenShift Express and converts it to the Ruby
# application template suitable for use with TorqueBox.

require 'fileutils'
require 'rexml/document'

root = File.expand_path(File.dirname(__FILE__))

# Remove Java files
FileUtils.rm(File.join(root, 'pom.xml')) if File.exist?(File.join(root, 'pom.xml'))
FileUtils.rm_r(File.join(root, 'src')) if File.exist?(File.join(root, 'src'))
FileUtils.rm_r(File.join(root, 'deployments')) if File.exist?(File.join(root, 'deployments'))

# Ensure .openshift/config/modules directory exists
FileUtils.mkdir_p(File.join(root, '.openshift', 'config', 'modules'))
FileUtils.touch(File.join(root, '.openshift', 'config', 'modules', '.gitkeep'))

# Add TorqueBox bits to standalone.xml
modules = %w(bootstrap core cdi jobs security services web)
standalone_xml = File.join(root, '.openshift', 'config', 'standalone.xml')
doc = REXML::Document.new(File.read(standalone_xml))
extensions = doc.root.get_elements('extensions').first
modules.each do |name|
  extensions.add_element('extension', 'module'=>"org.torquebox.#{name}")
end
profiles = doc.root.get_elements('//profile')
profiles.each do |profile|
  modules.each do |name|
    profile.add_element('subsystem', 'xmlns'=>"urn:jboss:domain:torquebox-#{name}:1.0")
  end
end
File.open(File.join(root, '.openshift', 'config', 'standalone.xml'), 'w') do |file|
  doc.write(file, 4)
end

# Add TorqueBox bits to .openshift/action_hooks/build
File.open(File.join(root, '.openshift', 'action_hooks', 'build'), 'w') do |file|
  file.write(<<-END_OF_BUILD)
#!/bin/bash
# This is a simple build script, place your post-deploy but pre-start commands
# in this script.  This script gets executed directly, so it could be python,
# php, ruby, etc.

JRUBY_VERSION="1.6.4"
TORQUEBOX_BUILD="382"
RACK_ENV="production"

cd ${OPENSHIFT_APP_DIR}

# Download a JRuby and plonk it next to our jboss.home.dir
if [ ! -d jruby-${JRUBY_VERSION} ]; then
    curl -o jruby-bin-${JRUBY_VERSION}.tar.gz "http://jruby.org.s3.amazonaws.com/downloads/${JRUBY_VERSION}/jruby-bin-${JRUBY_VERSION}.tar.gz"
    tar -xzf jruby-bin-${JRUBY_VERSION}.tar.gz
    rm jruby-bin-${JRUBY_VERSION}.tar.gz
    ln -sf jruby-${JRUBY_VERSION} jruby
fi

# Download a TorqueBox distribution and extract the modules
if [ ! -d ${OPENSHIFT_APP_DIR}${OPENSHIFT_APP_TYPE}/modules/org/torquebox ] && [ ! -d torquebox-${TORQUEBOX_BUILD}-modules ]; then
    curl -o torquebox-dist-modules.zip "http://repository-torquebox.forge.cloudbees.com/incremental/${TORQUEBOX_BUILD}/torquebox-dist-modules.zip"
    unzip -d torquebox-${TORQUEBOX_BUILD}-modules torquebox-dist-modules.zip
    rm torquebox-dist-modules.zip
fi

if [ ! -d ${OPENSHIFT_APP_DIR}${OPENSHIFT_APP_TYPE}/modules/org/torquebox ]; then
    # Symlink TorqueBox modules into the app's .openshift/config/modules directory
    mkdir -p ${OPENSHIFT_REPO_DIR}/.openshift/config/modules/org
    ln -s ${OPENSHIFT_APP_DIR}/torquebox-${TORQUEBOX_BUILD}-modules/torquebox ${OPENSHIFT_REPO_DIR}/.openshift/config/modules/org/torquebox
fi

# Add jruby to our path
export PATH=${OPENSHIFT_APP_DIR}/jruby/bin:$PATH

# Install Bundler if needed
if ! jruby -S gem list | grep bundler > /dev/null; then
    jruby -S gem install bundler
fi

# Install Rack if needed
if ! jruby -S gem list | grep rack > /dev/null; then
    jruby -S gem install rack
fi

# Install the TorqueBox gems if needed
if ! jruby -S gem list | grep "torquebox (2.x.incremental.${TORQUEBOX_BUILD})" > /dev/null; then
    jruby -S gem install torquebox --pre --source http://torquebox.org/2x/builds/${TORQUEBOX_BUILD}/gem-repo/
fi

# If .bundle isn't currently committed and a Gemfile is then bundle install
if [ ! -d ${OPENSHIFT_REPO_DIR}/.bundle ] && [ -f ${OPENSHIFT_REPO_DIR}/Gemfile ]; then
    jruby -J-Xmx256m -S bundle install --gemfile ${OPENSHIFT_REPO_DIR}/Gemfile
fi

# Ensure a deployments directory exists
mkdir -p ${OPENSHIFT_REPO_DIR}/deployments

# Create a deployment descriptor for this app
cat <<__EOF__ > ${OPENSHIFT_REPO_DIR}/deployments/app-knob.yml
---
application:
  root: ${OPENSHIFT_REPO_DIR}
  env: ${RACK_ENV}
__EOF__
touch ${OPENSHIFT_REPO_DIR}/deployments/app-knob.yml.dodeploy
END_OF_BUILD
end

# Add Ruby application template
File.open(File.join(root, 'config.ru'), 'w') do |file|
  file.write(<<-END_OF_CONFIG_RU)
app = lambda { |env|
  [200, { 'Content-Type' => 'text/html' }, "TorqueBox on OpenShift Express"]
}
run app
END_OF_CONFIG_RU
end
