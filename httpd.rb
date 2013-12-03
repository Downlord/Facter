#!/usr/bin/env ruby
require 'facter'
require 'facter/util/ip'

def has_address(interface)
  ip = Facter::Util::IP.get_interface_value(interface, 'ipaddress')
  if ip.nil?
    false
  else
    true
  end
end

def is_private(interface)
  rfc1918 = Regexp.new('^10\.|^172\.(?:1[6-9]|2[0-9]|3[0-1])\.|^192\.168\.')
  ip = Facter::Util::IP.get_interface_value(interface, 'ipaddress')
  if rfc1918.match(ip)
    true
  else
    false
  end
end

def find_networks
  found_public = found_private = false
  Facter::Util::IP.get_interfaces.each do |interface|
    if has_address(interface)
      if is_private(interface)
        found_private = true
      else
        found_public = true
      end
    end
  end
  [found_public, found_private]
end

# these facts check if any interface is on a public or private network
# they return the string true or false
# this fact will always be present

Facter.add(:on_public) do
  confine :kernel => Facter::Util::IP.supported_platforms
  setcode do
    found_public, found_private, inter_public, inter_private = find_networks
    found_public
  end
end

Facter.add(:on_private) do
  confine :kernel => Facter::Util::IP.supported_platforms
  setcode do
    found_public, found_private, inter_public, inter_private = find_networks
    found_private
  end
end
# these facts return the first public or private ip address found
# when iterating over the interfaces in alphabetical order
# if no matching address is found the fact won't be present
public_ip=''
Facter.add(:ipaddress_public) do
  confine :kernel => Facter::Util::IP.supported_platforms
  setcode do
    ip=""
    Facter::Util::IP.get_interfaces.each do |interface|
      if has_address(interface)
        if not is_private(interface)
          public_ip = Facter::Util::IP.get_interface_value(interface, 'ipaddress')
          break
        end
      end
    end
    public_ip
  end
end

private_ip=''
Facter.add(:ipaddress_private) do
  confine :kernel => Facter::Util::IP.supported_platforms
  setcode do
    Facter::Util::IP.get_interfaces.each do |interface|
      if has_address(interface)
        if is_private(interface)
          private_ip = Facter::Util::IP.get_interface_value(interface, 'ipaddress')
          break
        end
      end
    end
    private_ip
  end
end

private_if=''
Facter.add(:interface_private) do
  confine :kernel => Facter::Util::IP.supported_platforms
  setcode do
    Facter::Util::IP.get_interfaces.each do |interface|
      if has_address(interface)
        if is_private(interface)
          private_if = interface
          break
        end
      end
    end
    private_if
  end
end

public_if=''
Facter.add(:interface_public) do
  confine :kernel => Facter::Util::IP.supported_platforms
  setcode do
    Facter::Util::IP.get_interfaces.each do |interface|
      if has_address(interface)
        if not is_private(interface)
          public_if = interface
          break
        end
      end
    end
    public_if
  end
end

ip=''
port=''
name=''
apache_output=''
myurl=''

apache_runtime=Facter::Util::Resolution.exec('ps x | grep -v grep | egrep \'/usr/sbin/(httpd2-prefork|apache|apache2)\' |awk \'{ print $5;exit}\'')
if apache_runtime
  Facter.add("apache_active") do
    setcode do
      apache_runtime.chomp
    end
  end
  apache_version=Facter::Util::Resolution.exec("#{apache_runtime} -v|awk '{print $3;exit}'")
  if apache_version
    Facter.add("apache_version") do
    setcode do
      apache_version.chomp
    end
  end
  ipp=''
  apache_output=Facter::Util::Resolution.exec("#{apache_runtime} -S 2>&1")
  if apache_output
    ipp=public_ip
    apache_output.chomp.split("\n").each_with_index do |line,idx|

    if line =~ /.*is a NameVirtualHost.*/
      ipport=line.split(' ')[0]
      if ipport != ""
        ipp=ipport.split(':')[0]
        pport=ipport.split(':')[1]

        ssl=''
        if pport == "443"
          ssl=443
        end

        if ipp =~ /\*/
          ipp=public_ip
        end

        if ipp != "" and pport != ""
          Facter.add("apache_host_url") do
            setcode do
              "http://"+ipp+":"+pport+"/"
            end
          end
          Facter.add("apache_host_ip") do
            setcode do
              ipp
            end
          end
          Facter.add("apache_host_port") do
            setcode do
              ipport.split(':')[1]
            end
          end
        end

      end #if ipport != ""
    end # line =~ /.* is a NameVirtualHost.*/

    if line =~ /.*default server.*/
      ip=line.split(' ')[2]
      if ip != ""

        Facter.add("apache_host_name") do
          setcode do
            line.split(' ')[2]
          end
        end
      end
    end # if line =~ /.*default server.*/

    ip=''
    port=''
    name=''
    #ip = line.split(' ')[0].split(':')[0]
    #port = line.split(' ')[0].split(':')[1]
    #name = line.split(' ')[1]
    #print "ip = "+ip+"\n"
    #print "port = "+port+"\n"
    #print "name = "+name+"\n"
    #print "url = "+url+"\n"

    if(ip != "" and port != "" and name != "is")
      url = "http://" + ip + ":" + port + "/"
      Facter.add("apache_vhost_#{idx}_name") do
        setcode do
          name
        end
      end
      Facter.add("apache_vhost_#{idx}_port") do
        setcode do
          port
        end
      end
      Facter.add("apache_vhost_#{idx}_ip") do
        setcode do
          ip
        end
      end
      Facter.add("apache_vhost_#{idx}_url") do
        setcode do
          url
        end
      end
    end
      end
    end
  end

port=Facter::Util::Resolution.exec('lsof -P -iTCP -a -c \'/(apache|http)/i\' | awk -F \'( |:)\' \'!/NODE/{print $(NF-1)}\'|egrep \'(80|8080)\'|head -1')
#ipport=Facter::Util::Resolution.exec('lsof -P -iTCP -a -c \'/(apache|http)/i\' |grep LISTEN|sort -k9 -r|awk \'/\*/{ print $(NF-1);exit}\'')
if port
    #port=ipport.chomp.split(':')[1]
    if port != ""
      iip=public_ip
      myurl='http://'+public_ip+':'+port+'/'

      Facter.add("apache_host_url") do
        setcode do
          'http://'+public_ip+':'+port+'/'
        end
      end
      Facter.add("apache_host_port") do
        setcode do
          port
        end
      end

      Facter.add("apache_host_ip") do
        setcode do
          public_ip
        end
      end

    end
end

maxclients=`awk '($1=="MaxClients"){print $2;exit}' /etc/apache2/server-tuning.conf 2>/dev/null`
if maxclients
   Facter.add("apache_max_clients") do
        setcode do
          maxclients.chomp
        end
      end
end
end # if apache_runtime
