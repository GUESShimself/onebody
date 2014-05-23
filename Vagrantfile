# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you tknow what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure("2") do |config|
  config.vm.define "phusion" do |v|
    v.vm.provider "docker" do |d|
      # Uncomment the following line if you want to force vagrant to boot2docker
      # d.force_host_vm = true
      d.cmd     = ["/sbin/my_init", "--enable-insecure-key"]
      d.build_dir = "./"
      d.has_ssh = true
    end

    v.ssh.username = "root"
    #make this file and put your public key here.
    v.ssh.private_key_path = "./config/container/phusion.key"

  end
end
