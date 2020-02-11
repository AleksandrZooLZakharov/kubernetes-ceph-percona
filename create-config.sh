#!/bin/bash

#######################################
# all masters settings below must be same
#######################################

#etcd_version v3.3.18
#etcdToken gcp_etcd_token

#master01        35.228.254.190  10.166.15.221
#master02        35.228.102.146  10.166.15.217
#master03        35.228.244.91   10.166.15.216
#worknode01      35.228.61.254   10.166.15.219
#worknode02      35.228.149.225  10.166.15.218
#worknode03      35.228.52.116   10.166.15.220

# master01 ip address
export K8SHA_IP1=10.166.15.221

# master02 ip address
export K8SHA_IP2=10.166.15.217

# master03 ip address
export K8SHA_IP3=10.166.15.216


# master01 hostname
export K8SHA_HOSTNAME1=master01

# master02 hostname
export K8SHA_HOSTNAME2=master02

# master03 hostname
export K8SHA_HOSTNAME3=master03

#etcd tocken:
export ETCD_TOKEN=gcp_etcd_token

#etcd version
export ETCD_VERSION="v3.3.18"


##############################
# please do not modify anything below
##############################

# config etcd cluster
if [[ $1 == 'etcd' ]] || [[ $1 == 'all' ]]; then
  touch /etc/etcd.env
  echo PEER_NAME=$(hostname) > /etc/etcd.env
  echo PRIVATE_IP=$(hostname -i) >> /etc/etcd.env
  sed \
  -e "s/K8SHA_IPLOCAL/$(hostname -i)/g" \
  -e "s/K8SHA_IP1/$K8SHA_IP1/g" \
  -e "s/K8SHA_IP2/$K8SHA_IP2/g" \
  -e "s/K8SHA_IP3/$K8SHA_IP3/g" \
  -e "s/K8SHA_ETCDNAME/$(hostname)/g" \
  -e "s/K8SHA_HOSTNAME1/$K8SHA_HOSTNAME1/g" \
  -e "s/K8SHA_HOSTNAME2/$K8SHA_HOSTNAME2/g" \
  -e "s/K8SHA_HOSTNAME3/$K8SHA_HOSTNAME3/g" \
  etcd/etcd.service.tmpl > /etc/systemd/system/etcd.service
  echo etcd config copy to /etc/systemd/system/etcd.service
  cat /etc/systemd/system/etcd.service
fi

if [[ $1 == 'docker' ]]; then
  if [[ $(hostname) == master01 ]]; then
  etcd_host=etcd1
  elif [[ $(hostname) == master02 ]]; then
  etcd_host=etcd2
  elif [[ $(hostname) == master03 ]]; then
  etcd_host=etcd3
fi
  sed \
  -e "s/IPLOCAL/$(hostname -i)/g" \
  -e "s/HOSTNAME/$etcd_host/g" \
  -e "s/K8SHA_IP1/$K8SHA_IP1/g" \
  -e "s/K8SHA_IP2/$K8SHA_IP2/g" \
  -e "s/K8SHA_IP3/$K8SHA_IP3/g" \
  etcd-docker/docker-compose.yaml.tpl > etcd-docker/docker-compose.yaml
  echo docker-compose file create
  cat etcd-docker/docker-compose.yaml
fi

if [[ $1 == 'kubeadm' ]] || [[ $1 == 'all' ]]; then
  sed \
  -e "s/IPLOCAL/$(hostname -i)/g" \
  -e "s/HOSTNAME/$etcd_host/g" \
  -e "s/K8SHA_IP1/$K8SHA_IP1/g" \
  -e "s/K8SHA_IP2/$K8SHA_IP2/g" \
  -e "s/K8SHA_IP3/$K8SHA_IP3/g" \
  kubeadmin/kubeadm-init.yaml.tmpl > kubeadmin/kubeadm-init.yaml
  echo kubeadm-init file create
  cat kubeadmin/kubeadm-init.yaml
fi

if [[ $1 == 'haproxy' ]] || [[ $1 == 'all' ]]; then
  sed \
  -e "s/IPLOCAL/$(hostname -i)/g" \
  -e "s/K8SHA_IP1/$K8SHA_IP1/g" \
  -e "s/K8SHA_IP2/$K8SHA_IP2/g" \
  -e "s/K8SHA_IP3/$K8SHA_IP3/g" \
  haproxy/haproxy.cfg.tmpl > /etc/haproxy/haproxy.cfg
  systemctl restart haproxy.service
fi

if [[ $1 == 'ingress' ]] || [[ $1 == 'all' ]]; then
  sed \
  -e "s/K8SHA_IP1/$K8SHA_IP1/g" \
  -e "s/K8SHA_IP2/$K8SHA_IP2/g" \
  -e "s/K8SHA_IP3/$K8SHA_IP3/g" \
  ingress/service-nodeport.yaml.tmpl > ingress/service-nodeport.yaml
  cat ingress/service-nodeport.yaml
fi
