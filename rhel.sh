#!/bin/bash
################################################################################
# Date:     2013/03/14
# Author:   appleboy ( appleboy.tw AT gmail.com)
# Web:      http://blog.wu-boy.com
#
# Program:
#   Install all CentOS or Fefora program automatically
#
################################################################################

usage() {
    echo 'Usage: '$0' [--help|-h] [initial]'
    exit 1;
}

output() {
    printf "\E[0;33;40m"
    echo $1
    printf "\E[0m"
}

displayErr() {
    echo
    echo $1;
    echo
    exit 1;
}

initial() {
    output "Update all packages"
    # update package and upgrade Ubuntu
    yum -y update && yum -y upgrade
}

remove_package() {
    # ref http://www.cyberciti.biz/faq/centos-redhat-rhel-fedora-remove-nfs-services/
    output "Remove unnecessary Server Packages."
    chkconfig nfslock off
    chkconfig rpcgssd off
    chkconfig rpcidmapd off
    chkconfig portmap off
    chkconfig nfs off
    chkconfig cups off
    yum -y remove portmap nfs-utils cups

}

# Installing RHEL EPEL Repo on Centos 5.x or 6.x
# ref: http://www.rackspace.com/knowledge_center/article/installing-rhel-epel-repo-on-centos-5x-or-6x
install_epel() {
    # Centos 5.x
    # wget http://dl.fedoraproject.org/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm
    # wget http://rpms.famillecollet.com/enterprise/remi-release-5.rpm
    # rpm -Uvh remi-release-5*.rpm epel-release-5*.rpm
    # Centos 6.x
    wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
    wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
    rpm -Uvh remi-release-6*.rpm epel-release-6*.rpm
    initial
}

install_mariadb() {
    # https://downloads.mariadb.org/mariadb/repositories/
    # https://kb.askmonty.org/en/installing-mariadb-with-yum/
    wget https://gist.github.com/appleboy/5277201/raw/46e3d42e79e89eb3f5dcf3d2bb5965dc8c818ab7/MariaDB+5.5+CentOS -O /etc/yum.repos.d/MariaDB.repo
    initial
    yum -y install MariaDB-Galera-server MariaDB-client galera
}

install_php() {
    yum -y install php php-fpm php-mysql php-pdo php-gd
}

server() {
    # Remove unnecessary Packages.
    remove_package
    # stop iptables
    chkconfig iptables off
    /etc/init.d/iptables stop
    # install RHEL EPEL Repo.
    install_epel
    output "Install Server Packages."
    yum -y install make git tmux wget

    # CentOS Linux v6.x
    wget http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm
    rpm -ivh nginx-release-centos-6-0.el6.ngx.noarch.rpm
    # install web server.
    yum -y install nginx haproxy xinetd
    chkconfig nginx on
    chkconfig haproxy on
    # install MariaDB server
    install_mariadb
}

# Process command line...
while [ $# -gt 0 ]; do
    case $1 in
        --help | -h)
            usage $0
        ;;
        *)
            action=$1
            shift;
        ;;
    esac
done

test -z $action && usage $0

case $action in
    "initial")
        initial
        ;;
    "server")
        initial
        server
        ;;
    *)
        usage $0
        ;;
esac