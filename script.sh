#!/bin/sh

log(){
    echo '-------------------------------------'
    echo "$*"
}

deploy(){
    log "+ check config file: ${PLUGIN_CONFIG}/deploy/overlays/${PLUGIN_ENV}"
    cd ${PLUGIN_CONFIG}/deploy/overlays/${PLUGIN_ENV}

    if [ -z "${PLUGIN_TAG}" ]; then
        log "+ set tag & image: ${PLUGIN_IMAGE}:${DRONE_TAG}"
        kustomize edit set image ${PLUGIN_IMAGE}:${DRONE_TAG}
    else
        log "+ set image: ${PLUGIN_IMAGE}:${DRONE_BUILD_NUMBER}"
        kustomize edit set image ${PLUGIN_IMAGE}:${DRONE_BUILD_NUMBER}
    fi

    log "+ deploy {${PLUGIN_NAME}} to {${PLUGIN_NAMESPACE}} timeout: ${PLUGIN_TIMEOUT}s"
    kubectl apply -k . && kubedog rollout track deployment ${PLUGIN_NAME} -n ${PLUGIN_NAMESPACE} -t ${PLUGIN_TIMEOUT}
}

#FILES=$(cat git.txt)
#FILES=${FILES//,/ }
FILES=$(cat env.yaml | shyaml get-values checkList)

for element in $FILES
    do
        if [ $element == ${PLUGIN_NAME} ]; then
            IS_DEPLOY=true
            break
        fi
        echo $element
    done

#echo $FILES
IS_DEPLOY=false

if ${PLUGIN_CHECK} ; then
    for element in $FILES
    do
        if [ $element == ${PLUGIN_NAME} ]; then
            IS_DEPLOY=true
            break
        fi
    done

    if $IS_DEPLOY ; then
        deploy
    else
        log "+ skip module package deploy"
    fi

else
    log "+ skip check & start deploy"
    deploy
fi

