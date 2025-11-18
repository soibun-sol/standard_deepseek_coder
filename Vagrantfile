# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Use Ubuntu 22.04 LTS
  config.vm.box = "ubuntu/jammy64"
  
  # Set hostname for easy identification
  config.vm.hostname = "deepseek-coder"
  
  # VirtualBox-specific configuration
  config.vm.provider "virtualbox" do |vb|
    # GUI mode (optional - remove if you want headless)
    vb.gui = false
    
    # Resource allocation - ADJUST BASED ON YOUR HOST SYSTEM
    vb.memory = 12288    # 12GB RAM - minimum for 6.7B model
    vb.cpus = 4          # 4 CPU cores
    vb.name = "deepseek-coder-ubuntu" # Name in VirtualBox GUI
    
    # Enable hardware virtualization (if your system supports it)
    vb.customize ["modifyvm", :id, "--nested-hw-virt", "on"]
  end

  # Network configuration
  # Private network for host-guest communication
  config.vm.network "private_network", ip: "192.168.56.20"
  
  # Port forwarding for API access
  config.vm.network "forwarded_port", guest: 8000, host: 8000, auto_correct: true
  
  # Shared folder - syncs current directory to /vagrant in VM
  config.vm.synced_folder ".", "/vagrant"

  # Provisioning - run setup script automatically
  config.vm.provision "shell", path: "provision.sh"
  
  # Enable SSH agent forwarding for Git
  config.ssh.forward_agent = true
  
  # VirtualBox Guest Additions (auto-update)
  # config.vbguest.auto_update = true
end