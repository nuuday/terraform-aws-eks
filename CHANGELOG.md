
<a name="0.11.5"></a>
## [0.11.5](https://github.com/nuuday/terraform-aws-eks/compare/0.11.4...0.11.5) (2020-12-17)

### Fix

* fixed terraform versions


<a name="0.11.4"></a>
## [0.11.4](https://github.com/nuuday/terraform-aws-eks/compare/0.11.3...0.11.4) (2020-12-17)

### Fix

* fixing helm bug


<a name="0.11.3"></a>
## [0.11.3](https://github.com/nuuday/terraform-aws-eks/compare/0.11.2...0.11.3) (2020-12-17)

### Fix

* fixed prometheus flag


<a name="0.11.2"></a>
## [0.11.2](https://github.com/nuuday/terraform-aws-eks/compare/0.11.1...0.11.2) (2020-12-14)

### Fix

* bumbed minor version of prometheus operator


<a name="0.11.1"></a>
## [0.11.1](https://github.com/nuuday/terraform-aws-eks/compare/0.11.0...0.11.1) (2020-12-14)

### Fix

* fixed thanos configuration


<a name="0.11.0"></a>
## [0.11.0](https://github.com/nuuday/terraform-aws-eks/compare/0.10.0...0.11.0) (2020-12-14)

### Feat

* added thanos configuration values


<a name="0.10.0"></a>
## [0.10.0](https://github.com/nuuday/terraform-aws-eks/compare/0.9.1...0.10.0) (2020-12-14)

### Feat

* updated kubernetes addons


<a name="0.9.1"></a>
## [0.9.1](https://github.com/nuuday/terraform-aws-eks/compare/0.9.0...0.9.1) (2020-12-14)

### Fix

* added prometheus helm override variable


<a name="0.9.0"></a>
## [0.9.0](https://github.com/nuuday/terraform-aws-eks/compare/0.8.0...0.9.0) (2020-12-14)

### Feat

* upgraded prometheus version


<a name="0.8.0"></a>
## [0.8.0](https://github.com/nuuday/terraform-aws-eks/compare/0.7.1...0.8.0) (2020-12-11)

### Feat

* upgraded to support terraform 0.13


<a name="0.7.1"></a>
## [0.7.1](https://github.com/nuuday/terraform-aws-eks/compare/0.7.0...0.7.1) (2020-09-23)

### Chore

* fixed formatting


<a name="0.7.0"></a>
## [0.7.0](https://github.com/nuuday/terraform-aws-eks/compare/0.6.1...0.7.0) (2020-09-23)

### Feat

* Replaced prometheus with prometheus operator


<a name="0.6.1"></a>
## [0.6.1](https://github.com/nuuday/terraform-aws-eks/compare/0.6.0...0.6.1) (2020-09-14)

### Fix

* Added filter to configure if a loadbalancer port should be forwarded to the ingress-controller


<a name="0.6.0"></a>
## [0.6.0](https://github.com/nuuday/terraform-aws-eks/compare/0.5.1...0.6.0) (2020-08-27)

### Feat

* bumped cert-manager version


<a name="0.5.1"></a>
## [0.5.1](https://github.com/nuuday/terraform-aws-eks/compare/0.5.0...0.5.1) (2020-08-24)

### Fix

* Fixed cert-manager variable, removed variable that's not used anymore


<a name="0.5.0"></a>
## [0.5.0](https://github.com/nuuday/terraform-aws-eks/compare/0.4.5...0.5.0) (2020-08-24)

### Feat

* Updated all addons to newest version


<a name="0.4.5"></a>
## [0.4.5](https://github.com/nuuday/terraform-aws-eks/compare/0.4.4...0.4.5) (2020-08-13)

### Fix

* updated loki module version


<a name="0.4.4"></a>
## [0.4.4](https://github.com/nuuday/terraform-aws-eks/compare/0.4.3...0.4.4) (2020-08-13)

### Fix

* updated loki module version


<a name="0.4.3"></a>
## [0.4.3](https://github.com/nuuday/terraform-aws-eks/compare/0.4.2...0.4.3) (2020-08-13)

### Fix

* updated loki module version


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

