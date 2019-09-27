FROM centos:centos7

RUN curl -o mysql-connector-python-8.0.16-1.el7.x86_64.rpm http://www.mirrorservice.org/sites/ftp.mysql.com/Downloads/Connector-Python/mysql-connector-python-8.0.16-1.el7.x86_64.rpm \
	&& rpm -i mysql-connector-python-8.0.16-1.el7.x86_64.rpm \
	&& rm mysql-connector-python-8.0.16-1.el7.x86_64.rpm

RUN yum -y install https://dev.mysql.com/get/mysql57-community-release-el7-9.noarch.rpm \
	&& yum -y install mysql-server \
	&& yum -y install mysql-utilities \
	&& yum -y install openssh-clients \
	&& ln -s /usr/lib/python2.7/site-packages/mysql/utilities /usr/lib64/python2.7/site-packages/mysql/utilities \
	&& rm -rf /var/cache/yum/* \
	&& yum clean all
