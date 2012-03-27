[register]: https://openshift.redhat.com/app/user/new/express
[forums]: https://www.redhat.com/openshift/forums/express
[openshift-kb]: https://www.redhat.com/openshift/kb
[controlpanel]: https://openshift.redhat.com/app/dashboard


# TorqueBox on OpenShift Express

## QuickStart

1. [Register][] for OpenShift Express
1. Install OpenShift client gems - `gem install rhc`
1. Create a domain name - `rhc-create-domain -n mydomain -l username`
1. Create an AS7 application - `rhc-create-app -a myapp -t jbossas-7`
1. Convert the newly created Java application to Ruby for use with TorqueBox
    * `cd myapp`
    * Download `https://raw.github.com/torquebox/torquebox-openshift-express/master/java_to_ruby.rb` to the current directory
    * `ruby java_to_ruby.rb` to convert your application
1. java_to_ruby.rb automatically adds the changed files to your git repo
   and commits the result. If for some reason that failed, you can do the same with:
    * `git add .openshift`
    * `git add config.ru`
    * `git commit -am "Converted to TorqueBox"`
1. `git push` your new Ruby application
    * During this first push Express will download the necessary TorqueBox and
      JRuby installations then start your application
1. Visit your new application at http://myapp-mydomain.rhcloud.com
1. Edit your application and `git push` to deploy new changes


## Hint for Microsoft Windows users

If rhc-create-app on Windows fails with the message "Error in git clone", you have two options:

1. Run hc-create-app with --nogit to skip the automatic cloning of the new application repo.
1. Or visit the openshift express [Control Panel][controlpanel] and use the "Create an app..." form.

After that you can find the git url in the [Control Panel][controlpanel] und clone it with your favorite git gui tool.


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
