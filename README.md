# TorqueBox on OpenShift Express

* Remove Java files - `pom.xml`, `src/`, `deployments/`
* Add Ruby bits (config.ru, Gemfile, etc)
* `mkdir -p .openshift/config/modules`
* `touch .openshift/config/modules/.gitkeep`
* Patch (-p1) `.openshift/config/standalone.xml` w/ `standalone.xml.patch`
* Copy `build` to `.openshift/action_hooks/build`
