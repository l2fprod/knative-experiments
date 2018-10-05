#!/bin/bash
source local.env

yamls=( \
  config-domain.yaml \
  docker-secret.yaml \
  service-erp.yaml \
  service-controller.yaml \
  service-webui.yaml \
  ingress.yaml \
)

function install() {
  for yaml in "${yamls[@]}"
  do
    echo "applying ${yaml}"
    cat $yaml | envsubst | kubectl apply -f -
  done

  echo "Wait for all build pods to be completed and deployments to be running then access http://lw-webui.default.$INGRESS_DOMAIN"
  echo "watch"
  kubectl get pods --watch
}

function uninstall() {
  for yaml in "${yamls[@]}"
  do
    echo "deleting ${yaml}"
    cat $yaml | envsubst | kubectl delete -f -
  done
}

function dryrun() {
  for yaml in "${yamls[@]}"
  do
    echo "dry-run ${yaml}"
    cat $yaml | envsubst
  done
}

function usage() {
  echo "Usage: $0 [--install,--uninstall,--dry-run]"
}

case "$1" in
"--install" )
install
;;
"--uninstall" )
uninstall
;;
"--dry-run" )
dryrun
;;
* )
usage
;;
esac