# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  config.vm.hostname = "vagrant"
  config.vm.network "private_network", type: "dhcp"
  # ssh-agent forwarding from host to guest
  # On host add ~/.ssh/config and run eval `ssh-agent` && ssh-add
  # Host vagrant
  # ForwardAgent yes
  config.ssh.forward_agent = true
  config.trigger.before :ssh do |trigger|
    trigger.name = "Ensure ssh-agent"
    trigger.run = {inline: 'bash -c "ssh-add -l > /dev/null 2>&1 || (code=$?; echo \'start ssh-agent: eval `ssh-agent` && ssh-add\'; $(exit $code))"'}
  end
  config.vagrant.plugins = ["vagrant-disksize", "vagrant-scp"]
  config.disksize.size = '30GB'
  config.vm.provider "virtualbox" do |vb|
    vb.name = "vagrant"
    vb.cpus = "8"
    vb.memory = "32768"
  end
  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    # ssh-agent forwarding setup
    mkdir -p ~/.ssh && chmod 700 ~/.ssh
    ssh-keyscan -H github.com >> ~/.ssh/known_hosts
    ssh -T git@github.com
    # Install dependencies, clone repos, etc...
  SHELL
end
