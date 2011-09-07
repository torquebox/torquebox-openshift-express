[register]: https://openshift.redhat.com/app/user/new/express
[forums]: https://www.redhat.com/openshift/forums/express
[openshift-kb]: https://www.redhat.com/openshift/kb


# TorqueBox on OpenShift Express

## QuickStart

1. [Register][] for OpenShift Express
1. Install OpenShift client gems - `gem install rhc`
1. Create a domain name - `rhc-create-domain -n mydomain -l username`
1. Create an AS7 application - `rhc-create-app -a myapp -t jbossas-7.0`
1. Convert the newly created Java application to Ruby for use with TorqueBox
    * `cd myapp`
    * Download `https://raw.github.com/torquebox/torquebox-openshift-express/master/java_to_ruby.rb` to the current directory
    * `ruby java_to_ruby.rb` to convert your application
1. Confirm changes and commit result - be sure to `git add` the new files except for java_to_ruby.rb
    * `git add .openshift/config/modules`
    * `git add config.ru`
    * `git commit -am "Converted to TorqueBox"`
1. `git push` your new Ruby application
    * During this first push Express will download the necessary TorqueBox and
      JRuby installations then start your application
1. Visit your new application at http://myapp-mydomain.rhcloud.com
1. Edit your application and `git push` to deploy new changes


## Manual Conversion

If you'd prefer not to run java_to_ruby.rb and instead do the
conversion manually, follow the steps below.

1. Remove Java files - `pom.xml`, `src/`, `deployments/`
1. Add Ruby bits (config.ru, Gemfile, etc)
1. `mkdir -p .openshift/config/modules`
1. `touch .openshift/config/modules/.gitkeep`
1. Patch (-p1) `.openshift/config/standalone.xml` w/ `standalone.xml.patch`
1. Copy `build` to `.openshift/action_hooks/build`

## Outstanding Issues

* We've had some reports that when the rhc client tools are used under
  JRuby the password prompt behaves poorly. You can work around this
  by passing the -p option and your password on the commandline or
  help us fix it by submitting a pull request to
  <https://github.com/openshift/os-client-tools>


## Questions?

If you're stuck the best place to ask questions is in #torquebox for
anything TorqueBox-specific or in the [OpenShift Express
Forums][forums] for general OpenShift inquiries.

The [OpenShift Knowledge Base][openshift-kb] answers many common
questions such as how to deploy Rails and Sinatra applications on top
of OpenShift Express and the [OpenShift Express User
Guide][openshift-guide] goes into great detail on the client tools
(rhc-* commands) and their various options.
