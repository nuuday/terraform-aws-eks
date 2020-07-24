
<a name="0.4.2"></a>
## [0.4.2](https://github.com/nuuday/terraform-aws-eks/compare/0.4.1...0.4.2) (2020-07-24)

### Fix

* fixed spinnaker support and removed namespace creations features
* fixed roles name, removed trailing 's'


<a name="0.4.1"></a>
## [0.4.1](https://github.com/nuuday/terraform-aws-eks/compare/0.4.0...0.4.1) (2020-07-22)

### Fix

* fixed formatting


<a name="0.4.0"></a>
## [0.4.0](https://github.com/nuuday/terraform-aws-eks/compare/0.3.0...0.4.0) (2020-07-22)

### Feat

* Added support for Spinnaker and namespace creation


<a name="0.3.0"></a>
## [0.3.0](https://github.com/nuuday/terraform-aws-eks/compare/0.2.0...0.3.0) (2020-07-13)

### Feat

* Updated cluster_version to default to 1.17 and locked module version


<a name="0.2.0"></a>
## [0.2.0](https://github.com/nuuday/terraform-aws-eks/compare/0.1.1...0.2.0) (2020-07-10)

### Feat

* Updated addon version


<a name="0.1.1"></a>
## [0.1.1](https://github.com/nuuday/terraform-aws-eks/compare/0.1.0...0.1.1) (2020-07-06)

### Fix

* Locked all versions to a tag


<a name="0.1.0"></a>
## 0.1.0 (2020-07-06)

### Chore

* updated addons modules version
* verify module docs and formatting on all pushes

### Docs

* updated README.md
* add descriptions to remaining Terraform outputs
* add description to remaining TF variables

### Feat

* Added changelog
* Added loadbalancer, ingress, external-dns and cert-manager support
* Added tag and release workflow
* added new feature for asg group tags
* Moved last addons to addons repo
* Moved metrics-server to addons
* Moved termination to addon module
* Added admin bot user and fixed formatting
* Added default works and scheduled shutdown of worker nodes
* changed default logging configuration and retention
* Added more outputs
* added .github/settings.yaml
* Added kubernetes groups to map aws assumable roles
* Added kubernetes groups to map aws assumable roles
* Refactored eks module

### Fix

* Fixed file formatting
* changed username of admin robots to admin-robot
* fixed loki module path
* Added depends_on for modules not explicit referring to eks
* Added depends_on for modules not explicit referring to eks
* fixed reference variable
* Fixed module version
* fixed configuration
* enabled pre-commit
* deleted old and unneeded features
* added variables to support new features
* removed unneeded cni configuration
* Removed aws provider configuration
* Added token argument to kubectl command
* removed old addons
* Changed formatting workflow, it now only runs once.
* moved sample to samples folder
* enabling/disabling external-dns didn't have any effect

### Formatting

* Reformatted code
* clean up of line breaks

### Refactor

* Refactored addons, which i believe should be default addons and not modules
* Moved addons to separate folder to allow for testing

### Pull Requests

* Merge pull request [#7](https://github.com/nuuday/terraform-aws-eks/issues/7) from nuuday/worker_submodule

