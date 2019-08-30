#!/bin/sh

log(){
    echo '-------------------------------------'
    echo "$*"
    echo '-------------------------------------'
    echo ''
}


log "check config file: ${PLUGIN_CONFIG}/deploy/overlays/${PLUGIN_ENV}"
cd ${PLUGIN_CONFIG}/deploy/overlays/${PLUGIN_ENV}

if [ -z "${PLUGIN_TAG}" ]; then
    log "set tag & image: ${PLUGIN_IMAGE}:${DRONE_TAG}"
    kustomize edit set image ${PLUGIN_IMAGE}:${DRONE_TAG}
else
    log "set image: ${PLUGIN_IMAGE}:${DRONE_BUILD_NUMBER}"
    kustomize edit set image ${PLUGIN_IMAGE}:${DRONE_BUILD_NUMBER}
fi


log "deploy <${PLUGIN_NAME}> to <${PLUGIN_NAMESPACE}> . timeout: ${PLUGIN_TIMEOUT}s"
kubectl apply -k . && kubedog rollout track deployment ${PLUGIN_NAME} -n ${PLUGIN_NAMESPACE} -t ${PLUGIN_TIMEOUT}
