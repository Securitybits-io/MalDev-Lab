# -*- mode: ruby -*-
# vi: set ft=ruby :

# C2-Kali Kali-rolling C2 server
# Mal@Dev commando Development
# Mal@Rev commando Reverse
# Mal@Ware commando Victim

# kalilinux/rolling                    (virtualbox, 2024.2.0, (amd64))
# mayfly/windows_server2019            (virtualbox, 2023.10.19)
# mayfly/windows10                     (virtualbox, 2024.01.06)

Vagrant.configure("2") do |config|

  # Uncomment this depending on the provider you want to use
  ENV['VAGRANT_DEFAULT_PROVIDER'] = 'virtualbox'
  
  boxes = [
    { :name => "C2",    :ip => "192.168.56.30", :box => "kalilinux/rolling",         :os => "linux"},
    { :name => "Dev",   :ip => "192.168.56.31", :box => "mayfly/windows_server2019", :os => "windows"},
    { :name => "Rev",   :ip => "192.168.56.32", :box => "mayfly/windows_server2019", :os => "windows"},
    { :name => "Ware",  :ip => "192.168.56.40", :box => "mayfly/windows10",          :os => "windows"}
  ]

  config.vm.provider "virtualbox" do |v|
    v.memory = 4000
    v.cpus = 2
  end

  config.vm.provider "vmware_desktop" do |v|
    v.vmx["memsize"] = "4000"
    v.vmx["numvcpus"] = "2"
  end

  # disable forwarded port
  config.vm.network "forwarded_port", guest: 3389, host: 3389, id: 'rdp', auto_correct: true, disabled: true
  config.vm.network "forwarded_port", guest: 22, host: 2222, id: 'ssh', auto_correct: true, disabled: true

  # no autoupdate if vagrant-vbguest is installed
  if Vagrant.has_plugin?("vagrant-vbguest") then
    config.vbguest.auto_update = false
  end

  config.vm.boot_timeout = 600
  config.vm.graceful_halt_timeout = 600
  config.winrm.retry_limit = 30
  config.winrm.retry_delay = 10

  boxes.each do |box|
    config.vm.define box[:name] do |target|
      # BOX
      target.vm.provider "virtualbox" do |v|
        v.name = box[:name]
        v.customize ["modifyvm", :id, "--groups", "/Malware Development"]
      end
      target.vm.box_download_insecure = box[:box]
      target.vm.box = box[:box]
      if box.has_key?(:box_version)
        target.vm.box_version = box[:box_version]
      end

      # issues/49
      target.vm.synced_folder '.', '/Scripts', disabled: true

      # IP
      target.vm.network :private_network, ip: box[:ip]

      # OS specific
      if box[:os] == "windows"
        target.vm.guest = :windows
        target.vm.communicator = "winrm"
        target.vm.provision :shell, :path => "./Scripts/windows/Install-WMF3Hotfix.ps1", privileged: false

        # fix ip for vmware
        if ENV['VAGRANT_DEFAULT_PROVIDER'] == "vmware_desktop"
          target.vm.provision :shell, :path => "./Scripts/windows/fix_ip.ps1", privileged: false, args: box[:ip]
        end

      else
        target.vm.communicator = "ssh"
      end

      if box.has_key?(:forwarded_port)
        # forwarded port explicit
        box[:forwarded_port] do |forwarded_port|
          target.vm.network :forwarded_port, guest: forwarded_port[:guest], host: forwarded_port[:host], host_ip: "127.0.0.1", id: forwarded_port[:id]
        end
      end

    end
  end
end