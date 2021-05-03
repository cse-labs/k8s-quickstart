# Naming Convention

## Common naming criteria for all resources

- Max length: `1-63` chars
- Start with lower case character, can’t end in `-` or `_` or any special char

> Preferred names have all lower case
>> A preferred name can be regexed by `[a-z]([-a-z0-9]*[a-z0-9])?`

## Azure resource names

Azure resources consists of four parts: `( project-short-form )-[ environment-type ]-( identifier )-[ suffix ]`

- Mandatory: `(project-short-form)`.
- Mandatory: `[environment-type]` - usage env.
  - Possible val: `pre`, `test`, `stage`, `prod`, and `dev` [?]
    - `pre` is pre-production
- Optional: `(identifier)` - refers to descriptive label.
- Best effort to fit based on specific resource naming constraints.
- Each part will be separated by a hyphen `-`.
- Azure resource [suffix] can be found [here][1].
- Examples:
  - `ngsa-dev-grafana-kv`
  - `ngsa-pre-istio-cosmos`
  - `ngsa-prod-grafana-app`

## Kubernetes Labels

Labels are key/value pairs. Valid label keys have two segments: an optional *prefix* and *name*, separated by a slash (/) (e.g `helm.sh/chart`).

Prefixes are optional, and ensures that recommended labels do not get mixed up with private labels.

If prefix is omitted, the label is considered to be private to the user.

Detailed syntax and requirements can be found at: ["Kubernetes label syntax and charset"][4].

Adhering to ["Labels recommended by kubernetes"][3], following labels are required for essential kubernetes objects (pods, deployments, services, hpa etc.):

- app.kubernetes.io/name: name-of-the-component
- app.kubernetes.io/version: version-of-component
- app.kubernetes.io/component: type-of-the-component

Examples:

- app.kubernetes.io/name=ngsa
- app.kubernetes.io/version=1.16.0
- app.kubernetes.io/component=app
- app.kubernetes.io/component=database

## Kubernetes Namespaces

Kubernetes namespace names follow the format: `[Main Application Name]-[Optional Supporting Application name]`

Namespaces are broken up by application boundries. Our use case for namespaces is group all the Kubernetes resources needed to run a specific application. Multiple deployments of a single application can live in the same namespace. One example of this is `ngsa-cosmos` and `ngsa-memory` deployments in the `ngsa` namespace.

Examples:

- `fluentbit` for fluentbit
- `ngsa` for the ngsa-app
- `ngsa-l8r` for loderunner

## Kubernetes Workloads

Workloads names follow the format: `[Application name]-[Optional Identifier]`.

This allows multiple versions of an app to run in the same namespace. The optional identifier can be used to specify what makes the specific workload unique.

Examples:

- `fluentbit` for fluentbit
- `l8r` for loderunner
- `ngsa-cosmos` for cosmos version of ngsa-app
- `ngsa-memory` for in-memory version of ngsa-app

## Kubernetes Configs/Secrets

ConfigMap and Secret names follow the format: `[Application name]-[Optional Identifier]-[optional config|secrets]`

This allows for flexibilty to have multiple configs for a workload, and to also share configs between workload in the same namespace.

ConfigMap Examples:

- `fluentbit`
- `fluentbit-log-config`
- `ngsa-cosmos-config`
- `ngsa-memory-config`

Secret Examples:

- `fluentbit-secrets`
- `ngsa-secrets`

## DNS

The long form DNS follows the same pattern as other azure resources.

Examples

- `ngsa-mem-pre-west.cse.ms`
- `ngsa-cos-pre-west.cse.ms`

There is also a short form that uses the first letter of each section in the long form name.

Examples:

- `nmpw.cse.ms`
- `ncpw.cse.ms`

## Region and Zone

Region is the generic geographic location where the cluster is located. This is the same across cloud providers.

Examples:

- East
- West
- Central

Zone contains the cloud provider specific information: `[Cloud Provider Abbreviation]-[Cloud Provder Region]`

Examples:

- Az-EastUS2
- Az-WestUS2
- Az-CentralUS

## Resources

- [Azure resource naming and tagging convention][1]
- [Azure resource name restrictions][2]
- [Kubernetes recommended Label][3]
- [Kubernetes label syntax and charset][4]

[1]: https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations
[2]: https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules
[3]: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/
[4]: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#syntax-and-character-set
