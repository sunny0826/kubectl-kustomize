FROM alpine

LABEL maintainer="sunnydog0826@gmail.com"

ENV KUBE_LATEST_VERSION="v1.14.1"

RUN apk add --update ca-certificates \
 && apk add --update -t deps curl \
 && curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBE_LATEST_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl \
 && chmod +x /usr/local/bin/kubectl \
 && curl -L https://github.com/kubernetes-sigs/kustomize/releases/download/v2.0.3/kustomize_2.0.3_linux_amd64 -o /usr/local/bin/kustomize \
 && chmod +x /usr/local/bin/kustomize \
 && curl -L https://dl.bintray.com/flant/kubedog/v0.2.0/kubedog-linux-amd64-v0.2.0 -o /usr/local/bin/kubedog \
 && chmod +x /usr/local/bin/kubedog \
 && apk del --purge deps \
 && rm /var/cache/apk/*


WORKDIR /root
ENTRYPOINT ["kubectl"]
CMD ["help"]