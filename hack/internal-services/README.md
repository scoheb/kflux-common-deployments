# Setup for Testing Internal Services on Konflux Common Clusters

## Introduction
* This folder contains script to setup a *local kind cluster* with the Internal Services and required External Secrets.
* It currently will setup an Internal Services Controller that is configured to watch the internal, private stage p01 cluster.

## Setup
```
% cd hack/internal-services/scripts
% ./prepare-staging-internal-services.sh
% ./deploy-staging-internal-services.sh
```

## Testing
* Follow the logs of the internal service controller
```
kubectl logs -f deployment/controller-manager-staging-p01 -n stonesoup-int-srvc
```
* Navigate to the stage p01 cluster and create an InternalRequest
  * https://console-openshift-console.apps.stone-stage-p01.hpmt.p1.openshiftapps.com/k8s/ns/managed-release-team-tenant/appstudio.redhat.com~v1alpha1~InternalRequest/~new
* Paste the contents of the file *internal-request-test.yaml*
* Verify that the pipeline is triggered from the internal services logs

```
2025-07-09T18:59:23.470Z	INFO	controllers.internalRequest	Created PipelineRun to handle request	{"InternalRequest": "managed-release-team-tenant/simple-signing-pipeline-tx5bs", "PipelineRun.Name": "internalrequest-shm2h", "PipelineRun.Namespace": "stonesoup-int-srvc"}
2025-07-09T18:59:24.853Z	INFO	controllers.internalRequest	Request execution finished	{"InternalRequest": "managed-release-team-tenant/simple-signing-pipeline-tx5bs", "Succeeded": false}
2025-07-09T18:59:24.853Z	INFO	controllers.internalRequest	Running in debug mode. Skipping PipelineRun deletion	{"InternalRequest": "managed-release-team-tenant/simple-signing-pipeline-tx5bs"}
```
