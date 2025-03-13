# -*- mode: ruby -*-
# vi: set ft=ruby :
# https://github.com/rgl/customize-windows-vagrant

# C2-Kali Kali-rolling C2 server
# vagrant@Dev commando Development
# vagrant@Rev commando Reverse
# vagrant@Ware commando Victim

# kalilinux/rolling                    (virtualbox, 2024.2.0, (amd64))
# mayfly/windows_server2019            (virtualbox, 2023.10.19)
# mayfly/windows10                     (virtualbox, 2024.01.06)

Vagrant.configure("2") do |config|

  # Uncomment this depending on the provider you want to use
  ENV['VAGRANT_DEFAULT_PROVIDER'] = 'virtualbox'
  
  boxes = [
    { :name => "C2",      :ip => "192.168.56.130", :box => "kalilinux/rolling", :os => "linux"},
    { :name => "Dev",     :ip => "192.168.56.131", :box => "commando/dev",      :os => "windows", :size => "80GB" },
    { :name => "Rev",     :ip => "192.168.56.132", :box => "commando/rev",      :os => "windows", :size => "80GB" },
    { :name => "Victim",  :ip => "192.168.56.140", :box => "commando/victim",   :os => "windows" }
  ]

  config.vm.provider "virtualbox" do |v|
    v.memory = 4000
    v.cpus = 4
  end

  config.vm.provider "vmware_desktop" do |v|
    v.vmx["memsize"] = "4000"
    v.vmx["numvcpus"] = "4"
  end

  # disable forwarded port
  config.vm.network "forwarded_port", guest: 3389, host: 3389, id: 'rdp', auto_correct: true, disabled: true
  config.vm.network "forwarded_port", guest: 22, host: 2222, id: 'ssh', auto_correct: true, disabled: false

  config.vm.usable_port_range = 5000..5500

  # no autoupdate if vagrant-vbguest is installed
  if Vagrant.has_plugin?("vagrant-vbguest") then
    config.vbguest.auto_update = false
  end

  unless Vagrant.has_plugin?("vagrant-reload")
    puts 'Installing vagrant-reload Plugin...'
    system('vagrant plugin install vagrant-reload')
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
      target.vm.synced_folder 'Shared', '/Shared', disabled: false

      # IP
      target.vm.network :private_network, ip: box[:ip]

      # OS specific
      if box[:os] == "windows"
        target.vm.guest = :windows
        target.vm.communicator = "winrm"
                
        target.vm.provision :shell, :path => "./Scripts/windows/Install-WMF3Hotfix.ps1", privileged: false
        target.vm.provision :shell, :path => "./Scripts/windows/ReArm.ps1", privileged: true
        target.vm.provision :shell, :path => "./Scripts/windows/Set-Locale.ps1", privileged: true
        
        # fix ip for vmware
        if ENV['VAGRANT_DEFAULT_PROVIDER'] == "vmware_desktop"
          target.vm.provision :shell, :path => "./Scripts/windows/fix_ip.ps1", privileged: false, args: box[:ip]
        end

      else
        target.vm.communicator = "ssh"
        target.vm.synced_folder '.', '/vagrant', disabled: false
        target.vm.provision "shell", path: "./Scripts/linux/provision/provision.sh", :args => "--keyboard=se"
        
        target.vm.provision "ansible_local" do |ansible|
            ansible.playbook = "./Scripts/linux/playbook.yml"
            ansible.extra_vars = "./Scripts/linux/vars.yml"
        end
      end
      
      if box.has_key?(:size)
        target.vm.disk :disk, size: box[:size], primary: true
        if box[:os] == "windows"
          target.vm.provision :shell, :path => "./Scripts/windows/Resize-Primary.ps1"
        end
        # else
        #   pass
      end
      
      if box.has_key?(:forwarded_port)
        # forwarded port explicit
        box[:forwarded_port] do |forwarded_port|
          target.vm.network :forwarded_port, guest: forwarded_port[:guest], host: forwarded_port[:host], host_ip: "127.0.0.1", id: forwarded_port[:id]
        end
      end

      #target.vm.provision :reload
    end
  end
end