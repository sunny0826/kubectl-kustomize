# `kubectl` 镜像
![](https://img.shields.io/docker/cloud/automated/guoxudongdocker/kubectl.svg)
![Docker Pulls](https://img.shields.io/docker/pulls/guoxudongdocker/kubectl.svg)

用于 `drone` CI ，该镜像包括 `kubectl` `kustomize` `kubedog`

使用方法：

```yaml
kind: pipeline
name: {your-pipeline-name}

steps:
- name: Kubernetes 部署
  image: guoxudongdocker/kubectl
  volumes:
  - name: kube
    path: /root/.kube
  commands:
    - cd deploy/overlays/dev    # 这里使用 kustomize ,详细使用方法请见 https://github.com/kubernetes-sigs/kustomize
    - kustomize edit set image {your-docker-registry}:${DRONE_BUILD_NUMBER}
    - kubectl apply -k . && kubedog rollout track deployment {your-deployment-name} -n {your-namespace} -t {your-tomeout}

...

volumes:
- name: kube
  host:
    path: /tmp/cache/.kube  # kubeconfig 挂载位置

trigger:
  branch:
  - master  # 触发 CI 的分支
```