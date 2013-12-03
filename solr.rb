#!/usr/bin/env ruby
require 'facter'

#
# solr.rb - facter to show solr version
#

#solr_runtime=Facter::Util::Resolution.exec("/usr/bin/pgrep -f solrd -l|awk '{ print  $2}'")
solr_runtime=Facter::Util::Resolution.exec('ps xaw|grep -v grep|grep java|grep solr|awk \'{ print $9}\' | awk -F\'=\' \'{print $2}\'')
if solr_runtime
  Facter.add("solr_active") do
    setcode do
      solr_runtime.chomp
    end
  end
  solr_cmdline=Facter::Util::Resolution.exec('ps xaw|grep -v grep|grep java|awk \'/solr/{print $NF}\'')
  if solr_cmdline
    jar=solr_cmdline.split(" ")[-1]
    Facter.add("solr_version") do
      setcode do
        jar.chomp
      end
    end
  end
  solr_pis=Facter::Util::Resolution.exec('pgrep -of solr.solr.data')
  if solr_pis
    Facter.add("solr_pid") do
      setcode do
        solr_pis.chomp
      end
    end
  end

  ipport=Facter::Util::Resolution.exec('lsof -P -p $(pgrep -of solr.solr.data)|awk \'/\*.*LISTEN/{ print $9;exit}\'')
  if ipport
    ip=ipport.chomp.split(':')[0]
    port=ipport.chomp.split(':')[1]
    if ip != "" and port != ""
      Facter.add("solr_host_port") do
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
      Facter.add("solr_host_ip") do
        setcode do
          ip
        end
      end

      Facter.add("solr_host_url") do
        setcode do
          'http://'+ip+':'+port+'/'
        end
      end
    end
  end
end

