require 'facter'

mysql_client_version=''
mysql_client_version = Facter::Util::Resolution.exec('/usr/bin/mysql --version 2>/dev/null')
if mysql_client_version
Facter.add("mysql_client_version") do
    setcode do
        mysql_client_version.chomp.split(' ')[4].split(',').first
    end
end
end


mysqld_binary=`$(ps ax | awk '$5~/mysqld$/{print $5;exit}') -V 2>/dev/null|awk '{print $1}'`.chomp()
if mysqld_binary
        Facter.add("mysqld_binary") do
                setcode do
                        mysqld_binary
                end
        end
end

mysql_version=''
mysql_version=Facter::Util::Resolution.exec(mysqld_binary + ' --version 2>/dev/null')
if mysql_version
Facter.add("mysql_version") do
    setcode do
        mysql_version.chomp.split(' ')[2].split(',').first
    end
end
end

moutput=`$(ps ax | awk '$5~/mysqld$/{print $5;exit}') -V 2>/dev/null|awk '{print $3}'`.chomp()
if moutput
# devnull=`echo "mysqld running" >&2`
        Facter.add("mysql_active") do
                setcode do
                        moutput
                end
        end

        mysql_max_connections=Facter::Util::Resolution.exec('grep -h connections /etc/mysql/my.cnf /etc/my.cnf /etc/mysql/my.cnf ~/.my.cnf 2>/dev/null|awk "{ print \$NF;exit; }"')
        if mysql_max_connections
          Facter.add("mysql_max_connections") do
            setcode do
                mysql_max_connections
            end
          end
        end

        mysql_socket=''
        mysql_socket=Facter::Util::Resolution.exec(mysqld_binary + ' --verbose --help 2>/dev/null|awk "/^socket/{ print \$NF}"')
        if mysql_socket
        Facter.add("mysql_socket") do
            setcode do
                mysql_socket
            end
        end
        end

        mysql_slave_running=''
        mysql_slave_running=Facter::Util::Resolution.exec("mysql -Bse 'show status where Variable_name = \"Slave_running\"' 2>/dev/null")
        if mysql_slave_running
        Facter.add("mysql_slave_running") do
            setcode do
                mysql_slave_running.chomp.split(' ')[1]
            end
        end
        end

        mysql_database_names=''
        #mysql_database_names=Facter::Util::Resolution.exec('echo $(mysql -Bse "show databases" 2>/dev/null)|sed -e "s/ /,/g"')
        mysql_database_names=Facter::Util::Resolution.exec('echo $(mysql -Bse "show databases" 2>/dev/null|egrep \'(mysql|mol)\') | sed -e "s/ /,/g"')
        if mysql_database_names
        #databases = split($mysql_database_names, ' ').sort.join(',')
        Facter.add('mysql_database_names') do
          setcode do
            mysql_database_names
          end
        end
        end

end
