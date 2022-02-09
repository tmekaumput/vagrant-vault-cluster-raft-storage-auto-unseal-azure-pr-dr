# -*- mode: ruby -*-
# vi: set ft=ruby :

GID=1001
UID=1001

shared_dir="/var/shared"
primary_shared_dir="#{shared_dir}/primary"
pr_shared_dir="#{shared_dir}/pr"
dr_shared_dir="#{shared_dir}/dr"
client_id=ENV['CLIENT_ID']
client_secret=ENV['CLIENT_SECRET']
tenant_id=ENV['TENANT_ID']
vault_name=ENV['VAULT_NAME']
key_name=ENV['KEY_NAME']

pri_leader_node = {
  :id => "pri_leader_node",
  :ip => "192.168.56.190",
  :hostname => "prim-vault-leader",
  :api_addr => "http://192.168.56.190:8200"
}

pri_followers = [
  {
    :id => "pri_follower_node1",
    :ip => "192.168.56.191",
    :hostname => "pri-vault-follower1",
    :ui_port => 8202
  },
  {
    :id => "pri_follower_node2",
    :ip => "192.168.56.192",
    :hostname => "pri-vault-follower2",
    :ui_port => 8204
  }
]

dr_leader_node = {
  :id => "dr_leader_node",
  :ip => "192.168.56.200",
  :hostname => "dr-vault-leader",
  :api_addr => "http://192.168.56.200:8200"
}

dr_followers = [
  {
    :id => "dr_follower_node1",
    :ip => "192.168.56.201",
    :hostname => "dr-vault-follower1",
    :ui_port => 9202
  },
  {
    :id => "dr_follower_node2",
    :ip => "192.168.56.202",
    :hostname => "dr-vault-follower2",
    :ui_port => 9204
  }
]

pr_leader_node = {
  :id => "pr_leader_node",
  :ip => "192.168.56.210",
  :hostname => "pr-vault-leader",
  :api_addr => "http://192.168.56.200:8200"
}

pr_followers = [
  {
    :id => "pr_follower_node1",
    :ip => "192.168.56.211",
    :hostname => "pr-vault-follower1",
    :ui_port => 9202
  },
  {
    :id => "pr_follower_node2",
    :ip => "192.168.56.212",
    :hostname => "pr-vault-follower2",
    :ui_port => 9204
  }
]

Vagrant.configure("2") do |config|
  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory", "1024"]
    vb.customize ["modifyvm", :id, "--cpus", "1"]
    vb.customize ["modifyvm", :id, "--cpuexecutioncap", "50"]
    vb.customize ["modifyvm", :id, "--chipset", "ich9"]
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
  end

  config.vm.define "pri_vault_leader" do |vault_leader|
    vault_leader.vm.box = "bento/centos-7.9"
    vault_leader.vm.box_version = "202110.25.0"
    vault_leader.vm.hostname = pri_leader_node[:hostname]
    vault_leader.vm.network "private_network", ip: pri_leader_node[:ip]
    vault_leader.vm.network "forwarded_port", guest: 8200, host: 9200, auto_correct: true
    vault_leader.vm.provision "shell", path: "scripts/setup-user.sh", args: ["vault", UID, GID]
    vault_leader.vm.synced_folder "data/", shared_dir, owner: "vault",  group: "vault", :mount_options => ["uid=#{UID},gid=#{GID},dmode=744,fmode=744"]
    vault_leader.vm.provision "file", source: "./license.txt", destination: "/tmp/license.txt"
    vault_leader.vm.provision "shell", path: "scripts/common.sh"
    vault_leader.vm.provision "shell", path: "scripts/install-vault.sh", args: pri_leader_node[:ip]
    vault_leader.vm.provision "shell", path: "scripts/create-systemd-unit.sh"
    vault_leader.vm.provision "shell", path: "scripts/create-configs.sh", args: [pri_leader_node[:id], pri_leader_node[:ip], key_name, pri_leader_node[:id], pri_leader_node[:api_addr], client_id, client_secret, tenant_id, vault_name, primary_shared_dir] 

    vault_leader.vm.provision "shell", inline: "sudo systemctl enable vault.service"
    vault_leader.vm.provision "shell", inline: "sudo systemctl start vault"
    vault_leader.vm.provision "shell", path: "scripts/setup-leader-node.sh", args: primary_shared_dir
    vault_leader.vm.provision "shell", path: "scripts/setup-primary.sh", args: primary_shared_dir
  end

  pri_followers.each do |follower|
    config.vm.define follower[:id] do |follower_node|
      follower_node.vm.box = "bento/centos-7.9"
      follower_node.vm.box_version = "202110.25.0"
      follower_node.vm.hostname = follower[:hostname]
      follower_node.vm.network "private_network", ip: follower[:ip]
      follower_node.vm.network "forwarded_port", guest: 8200, host: follower[:ui_port], auto_correct: true
      follower_node.vm.provision "shell", path: "scripts/setup-user.sh", args: ["vault", UID, GID]
      follower_node.vm.synced_folder "data/", shared_dir, owner: "vault",  group: "vault", :mount_options => ["uid=#{UID},gid=#{GID},dmode=744,fmode=744"]
      follower_node.vm.provision "file", source: "./license.txt", destination: "/tmp/license.txt"
      follower_node.vm.provision "shell", path: "scripts/common.sh"
      follower_node.vm.provision "shell", path: "scripts/install-vault.sh", args: follower[:ip]
      follower_node.vm.provision "shell", path: "scripts/create-systemd-unit.sh"
      follower_node.vm.provision "shell", path: "scripts/create-configs.sh", args: [follower[:id], follower[:ip], key_name, pri_leader_node[:id], pri_leader_node[:api_addr], client_id, client_secret, tenant_id, vault_name, primary_shared_dir]
      follower_node.vm.provision "shell", inline: "sudo systemctl enable vault.service"
      follower_node.vm.provision "shell", inline: "sudo systemctl start vault"
    end
  end

  config.vm.define "dr_vault_leader" do |vault_leader|
    vault_leader.vm.box = "bento/centos-7.9"
    vault_leader.vm.box_version = "202110.25.0"
    vault_leader.vm.hostname = dr_leader_node[:hostname]
    vault_leader.vm.network "private_network", ip: dr_leader_node[:ip]
    vault_leader.vm.network "forwarded_port", guest: 8200, host: 10200, auto_correct: true
    vault_leader.vm.provision "shell", path: "scripts/setup-user.sh", args: ["vault", UID, GID]
    vault_leader.vm.synced_folder "data/", shared_dir, owner: "vault",  group: "vault", :mount_options => ["uid=#{UID},gid=#{GID},dmode=744,fmode=744"]
    vault_leader.vm.provision "file", source: "./license.txt", destination: "/tmp/license.txt"
    vault_leader.vm.provision "shell", path: "scripts/common.sh"
    vault_leader.vm.provision "shell", path: "scripts/install-vault.sh", args: dr_leader_node[:ip]
    vault_leader.vm.provision "shell", path: "scripts/create-systemd-unit.sh"
    vault_leader.vm.provision "shell", path: "scripts/create-configs.sh", args: [dr_leader_node[:id], dr_leader_node[:ip], key_name, dr_leader_node[:id], dr_leader_node[:api_addr], client_id, client_secret, tenant_id, vault_name, dr_shared_dir]

    vault_leader.vm.provision "shell", inline: "sudo systemctl enable vault.service"
    vault_leader.vm.provision "shell", inline: "sudo systemctl start vault"
    vault_leader.vm.provision "shell", path: "scripts/setup-leader-node.sh", args: dr_shared_dir
    vault_leader.vm.provision "shell", path: "scripts/setup-dr.sh", args: dr_shared_dir
  end

  dr_followers.each do |follower|
    config.vm.define follower[:id] do |follower_node|
      follower_node.vm.box = "bento/centos-7.9"
      follower_node.vm.box_version = "202110.25.0"
      follower_node.vm.hostname = follower[:hostname]
      follower_node.vm.network "private_network", ip: follower[:ip]
      follower_node.vm.network "forwarded_port", guest: 8200, host: follower[:ui_port], auto_correct: true
      follower_node.vm.provision "shell", path: "scripts/setup-user.sh", args: ["vault", UID, GID]
      follower_node.vm.synced_folder "data/", shared_dir, owner: "vault",  group: "vault", :mount_options => ["uid=#{UID},gid=#{GID},dmode=744,fmode=744"]
      follower_node.vm.provision "file", source: "./license.txt", destination: "/tmp/license.txt"
      follower_node.vm.provision "shell", path: "scripts/common.sh"
      follower_node.vm.provision "shell", path: "scripts/install-vault.sh", args: follower[:ip]
      follower_node.vm.provision "shell", path: "scripts/create-systemd-unit.sh"
      follower_node.vm.provision "shell", path: "scripts/create-configs.sh", args: [follower[:id], follower[:ip], key_name, dr_leader_node[:id], dr_leader_node[:api_addr], client_id, client_secret, tenant_id, vault_name, dr_shared_dir]
      follower_node.vm.provision "shell", inline: "sudo systemctl enable vault.service"
      follower_node.vm.provision "shell", inline: "sudo systemctl start vault"
    end
  end

  config.vm.define "pr_vault_leader" do |vault_leader|
    vault_leader.vm.box = "bento/centos-7.9"
    vault_leader.vm.box_version = "202110.25.0"
    vault_leader.vm.hostname = pr_leader_node[:hostname]
    vault_leader.vm.network "private_network", ip: pr_leader_node[:ip]
    vault_leader.vm.network "forwarded_port", guest: 8200, host: 10200, auto_correct: true
    vault_leader.vm.provision "shell", path: "scripts/setup-user.sh", args: ["vault", UID, GID]
    vault_leader.vm.synced_folder "data/", shared_dir, owner: "vault",  group: "vault", :mount_options => ["uid=#{UID},gid=#{GID},dmode=744,fmode=744"]
    vault_leader.vm.provision "file", source: "./license.txt", destination: "/tmp/license.txt"
    vault_leader.vm.provision "shell", path: "scripts/common.sh"
    vault_leader.vm.provision "shell", path: "scripts/install-vault.sh", args: pr_leader_node[:ip]
    vault_leader.vm.provision "shell", path: "scripts/create-systemd-unit.sh"
    vault_leader.vm.provision "shell", path: "scripts/create-configs.sh", args: [pr_leader_node[:id], pr_leader_node[:ip], key_name, pr_leader_node[:id], pr_leader_node[:api_addr], client_id, client_secret, tenant_id, vault_name, pr_shared_dir]

    vault_leader.vm.provision "shell", inline: "sudo systemctl enable vault.service"
    vault_leader.vm.provision "shell", inline: "sudo systemctl start vault"
    vault_leader.vm.provision "shell", path: "scripts/setup-leader-node.sh", args: pr_shared_dir
    vault_leader.vm.provision "shell", path: "scripts/setup-pr.sh", args: pr_shared_dir
  end

  pr_followers.each do |follower|
    config.vm.define follower[:id] do |follower_node|
      follower_node.vm.box = "bento/centos-7.9"
      follower_node.vm.box_version = "202110.25.0"
      follower_node.vm.hostname = follower[:hostname]
      follower_node.vm.network "private_network", ip: follower[:ip]
      follower_node.vm.network "forwarded_port", guest: 8200, host: follower[:ui_port], auto_correct: true
      follower_node.vm.provision "shell", path: "scripts/setup-user.sh", args: ["vault", UID, GID]
      follower_node.vm.synced_folder "data/", shared_dir, owner: "vault",  group: "vault", :mount_options => ["uid=#{UID},gid=#{GID},dmode=744,fmode=744"]
      follower_node.vm.provision "file", source: "./license.txt", destination: "/tmp/license.txt"
      follower_node.vm.provision "shell", path: "scripts/common.sh"
      follower_node.vm.provision "shell", path: "scripts/install-vault.sh", args: follower[:ip]
      follower_node.vm.provision "shell", path: "scripts/create-systemd-unit.sh"
      follower_node.vm.provision "shell", path: "scripts/create-configs.sh", args: [follower[:id], follower[:ip], key_name, pr_leader_node[:id], pr_leader_node[:api_addr], client_id, client_secret, tenant_id, vault_name, pr_shared_dir]
      follower_node.vm.provision "shell", inline: "sudo systemctl enable vault.service"
      follower_node.vm.provision "shell", inline: "sudo systemctl start vault"
    end
  end

end
