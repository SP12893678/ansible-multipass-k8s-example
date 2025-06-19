#!/bin/bash

# 啟動 master 節點
multipass launch jammy --name k8s-master --cpus 2 --memory 2G --disk 10G

# 啟動 worker 節點
multipass launch jammy --name k8s-worker1 --cpus 2 --memory 2G --disk 10G
multipass launch jammy --name k8s-worker2 --cpus 2 --memory 2G --disk 10G

# 取得 IP
sleep 5
echo "\nMultipass Instances:"
multipass list

echo "\Set ssh key:"
# 設置SSH連線憑證 ~/.ssh/id_rsa.pub
multipass exec k8s-master -- bash -c "echo '$(cat ~/.ssh/id_rsa.pub)' >> ~/.ssh/authorized_keys"
multipass exec k8s-worker1 -- bash -c "echo '$(cat ~/.ssh/id_rsa.pub)' >> ~/.ssh/authorized_keys"
multipass exec k8s-worker2 -- bash -c "echo '$(cat ~/.ssh/id_rsa.pub)' >> ~/.ssh/authorized_keys"

# 設置 known_hosts，避免 SSH 連線時的 authenticity prompt
echo -e "\nAdd SSH keys to known_hosts to avoid authenticity prompt:"
for vm in k8s-master k8s-worker1 k8s-worker2; do
    ip=$(multipass info $vm | grep IPv4 | awk '{print $2}')
    echo "Adding $vm ($ip) to known_hosts"
    ssh-keyscan -H $ip >> ~/.ssh/known_hosts 2>/dev/null
done

# 設置 inventory.yaml
MASTER_IP=$(multipass info k8s-master | grep IPv4 | awk '{print $2}')
WORKER1_IP=$(multipass info k8s-worker1 | grep IPv4 | awk '{print $2}')
WORKER2_IP=$(multipass info k8s-worker2 | grep IPv4 | awk '{print $2}')

cp inventory.template.yaml inventory.yaml

sed -i '' \
  -e "s/MASTER_IP/${MASTER_IP}/g" \
  -e "s/WORKER1_IP/${WORKER1_IP}/g" \
  -e "s/WORKER2_IP/${WORKER2_IP}/g" \
  inventory.yaml