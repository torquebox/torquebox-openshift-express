[register]: https://openshift.redhat.com/app/user/new/express


# TorqueBox on OpenShift Express

## QuickStart

* [Register][] for OpenShift Express
* Install OpenShift client gems - `gem install rhc`
* Create a domain name - `rhc-create-domain -n mydomain -l username`
* Create an AS7 application - `rhc-create-app -a myapp -t jbossas-7.0`
* Convert the newly created Java application to Ruby for use with TorqueBox
  * `cd myapp`
  * Download `https://raw.github.com/torquebox/torquebox-openshift-express/master/java_to_ruby.rb` to the current directory
  * `ruby java_to_ruby.rb` to convert your application
* Confirm changes and commit result - be sure to `git add` the new files except for java_to_ruby.rb
* `git push` your new Ruby application
  * During this first push Express will download the necessary TorqueBox and
    JRuby installations then start your application


## Manual Conversion

If you'd prefer not to run java_to_ruby.rb and instead do the
conversion manually, follow the steps below.

* Remove Java files - `pom.xml`, `src/`, `deployments/`
* Add Ruby bits (config.ru, Gemfile, etc)
* `mkdir -p .openshift/config/modules`
* `touch .openshift/config/modules/.gitkeep`
* Patch (-p1) `.openshift/config/standalone.xml` w/ `standalone.xml.patch`
* Copy `build` to `.openshift/action_hooks/build`
