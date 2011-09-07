[register]: https://openshift.redhat.com/app/user/new/express
[forums]: https://www.redhat.com/openshift/forums/express
[openshift-kb]: https://www.redhat.com/openshift/kb


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
  * `git add .openshift/config/modules`
  * `git add config.ru`
  * `git commit -am "Converted to TorqueBox"`
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


## Questions?

If you're stuck the best place to ask questions is in #torquebox for
anything TorqueBox-specific or in the [OpenShift Express
Forums][forums] for general OpenShift inquiries.

The [OpenShift Knowledge Base][openshift-kb] answers many common
questions such as how to deploy Rails and Sinatra applications on top
of OpenShift Express and the [OpenShift Express User
Guide][openshift-guide] goes into great detail on the client tools
(rhc-* commands) and their various options.
