# Ansible Multipass K8s Example

## Prerequisite
- Ansible
- Multipass

## Get Started

### Setup VM Environment
This will create one k8s-master VM and two k8s-worker VMs:
```shell
sh setup.sh
```

### Setup K8s Environment
```shell
ansible-playbook site.yml -i inventory.yaml
```