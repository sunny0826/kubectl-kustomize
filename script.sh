#!/bin/sh

set -e

log(){
    echo '-------------------------------------'
    echo "$*"
}

deploy(){
    log "+ check config file: ${PLUGIN_CONFIG}"
    cd ${PLUGIN_CONFIG}

    IMAGE=$(cat ../../base/deployment.yaml | shyaml get-value spec.template.spec.containers.0.image)
    if [ ${DRONE_TAG} ]; then
        log "+ set tag & image: ${IMAGE%:*}:${DRONE_TAG}"
        kustomize edit set image ${IMAGE%:*}:${DRONE_TAG}
    else
        log "+ set image: ${IMAGE%:*}:${DRONE_BUILD_NUMBER}"
        kustomize edit set image ${IMAGE%:*}:${DRONE_BUILD_NUMBER}
    fi
    NAMESPACE=$(cat kustomization.yaml | shyaml get-value namespace)
    NAME=$(cat ../../base/deployment.yaml | shyaml get-value metadata.name)
    log "+ deploy [$NAME] to [$NAMESPACE] timeout: ${PLUGIN_TIMEOUT}s"
    kubectl apply -k . && kubedog rollout track deployment $NAME -n $NAMESPACE -t ${PLUGIN_TIMEOUT}
}

FILES=$(cat env.yaml | shyaml get-values checkList)

for element in $FILES
    do
        if [ $element == ${PLUGIN_MODNAME} ]; then
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
        if [ $element == ${PLUGIN_MODNAME} ]; then
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

