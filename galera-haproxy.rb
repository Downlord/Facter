#!/usr/bin/env ruby
require 'facter'

#
# galera_haproxy.rb - facter to show galera_haproxy version
#

galera_haproxy_runtime=Facter::Util::Resolution.exec('ps ax | grep -v grep | egrep \'(galera-haproxy)\' |awk \'{ print $5;exit}\'')
if galera_haproxy_runtime
  #print "VERSION:"+galera_haproxy_version+"\n\n"
  Facter.add("galera_haproxy_active") do
    setcode do
      galera_haproxy_runtime.chomp
    end
  end
  galera_haproxy_version=Facter::Util::Resolution.exec("#{galera_haproxy_runtime} -V 2>&1|tr '()' ' ' |awk '{print $3;exit}'")
  if galera_haproxy_version
    Facter.add("galera_haproxy_version") do
     setcode do
         galera_haproxy_version.chomp
     end
   end
  ipport=Facter::Util::Resolution.exec('lsof -P -iTCP -a -c "/galera_haproxy/i" | grep LIST  | grep IPv4 |sort -k9 -r|awk \'/\*/{ print $(NF-1);exit}\'')
  if ipport
    ip=ipport.chomp.split(':')[0]
    port=ipport.chomp.split(':')[1]
    if ip != "" and port != ""

      Facter.add("galera_haproxy_host_port") do
        setcode do
          port
        end
      end
      iip=Facter.value(:ipaddress_public)
      Facter.add("galera_haproxy_host_ip") do
        setcode do
          iip
        end
      end
      if iip != "" and port != ""
      Facter.add("galera_haproxy_host_url") do
        setcode do
          'http://'+iip+':'+port+'/'
        end
      end
      end

    end
end
  end
end
