# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you tknow what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure("2") do |config|
  config.vm.define "phusion" do |v|
    v.vm.provider "docker" do |d|
      #d.cmd     = ["/sbin/my_init", "--enable-insecure-key"]
      d.image   = "phusion/baseimage"
      #d.vagrant_vagrantfile = "./config/container/Vagrantfile"
      #d.has_ssh = true
    end

    #v.ssh.username = "root"
    #v.ssh.private_key_path = "phusion.key"

    v.vm.provision "shell", inline: "echo Hello"
  end
end
