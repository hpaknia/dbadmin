FROM centos:centos7

RUN rpm -i https://dev.mysql.com/get/mysql57-community-release-el7-9.noarch.rpm \
       http://www.mirrorservice.org/sites/ftp.mysql.com/Downloads/Connector-Python/mysql-connector-python-8.0.16-1.el7.x86_64.rpm \
       https://repo.percona.com/yum/percona-release-latest.noarch.rpm

RUN yum -y install mysql-server mysql-utilities openssh-clients percona-xtrabackup-24 \
	&& ln -s /usr/lib/python2.7/site-packages/mysql/utilities /usr/lib64/python2.7/site-packages/mysql/utilities \
	&& rm -rf /var/cache/yum/* \
	&& yum clean all
