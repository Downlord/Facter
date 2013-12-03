#!/usr/bin/env ruby
require 'facter'

#
# varnish.rb - facter to show varnish version
#

#varnish_runtime=Facter::Util::Resolution.exec("/usr/bin/pgrep -f varnishd -l|awk '{ print  $2}'")
varnish_runtime=Facter::Util::Resolution.exec('ps x | grep -v grep | egrep \'sbin/varnishd\' |awk \'{ print $5;exit}\'')
if varnish_runtime
  Facter.add("varnish_active") do
    setcode do
      varnish_runtime.chomp
    end
  end
  varnish_version=Facter::Util::Resolution.exec("${varnish_runtime} -V 2>&1|tr '()' ' ' |awk '{print $2;exit}'")
  if varnish_version
    Facter.add("varnish_version") do
      setcode do
        varnish_version.chomp
      end
    end
  end

  ipport=Facter::Util::Resolution.exec('lsof -P -c /varnish/i|sort -r|awk \'/\*.*LISTEN/{ print $9;exit}\'')
  if ipport
    ip=ipport.chomp.split(':')[0]
    port=ipport.chomp.split(':')[1]
    if ip != "" and port != ""
      Facter.add("varnish_host_port") do
        setcode do
          port
        end
      end
      if ip == '*'
        if Facter.value(:ipaddress_eth0) =~ /^193.*/
          ip=Facter.value(:ipaddress_eth0)
        elsif Facter.value(:ipaddress_eth1) =~ /^193.*/
          ip=Facter.value(:ipaddress_eth1)
        elsif Facter.value(:ipaddress_eth2) =~ /^193.*/
          ip=Facter.value(:ipaddress_eth2)
        elsif Facter.value(:ipaddress_eth3) =~ /^193.*/
          ip=Facter.value(:ipaddress_eth3)
        elsif Facter.value(:ipaddress_eth4) =~ /^193.*/
          ip=Facter.value(:ipaddress_eth4)
        elsif Facter.value(:ipaddress_eth5) =~ /^193.*/
          ip=Facter.value(:ipaddress_eth5)
        elsif Facter.value(:ipaddress_eth6) =~ /^193.*/
          ip=Facter.value(:ipaddress_eth6)
        elsif Facter.value(:ipaddress_eth7) =~ /^193.*/
          ip=Facter.value(:ipaddress_eth7)
        elsif Facter.value(:ipaddress_eth8) =~ /^193.*/
          ip=Facter.value(:ipaddress_eth8)
        elsif Facter.value(:ipaddress_eth9) =~ /^193.*/
          ip=Facter.value(:ipaddress_eth9)
        else
          ip=Facter.value(:ipaddress)
        end
      end
      Facter.add("varnish_host_ip") do
        setcode do
          ip
        end
      end

      Facter.add("varnish_host_url") do
        setcode do
          'http://'+ip+':'+port+'/'
        end
      end
    end
  end
end
