FROM centos:centos7

RUN yum -y install https://dev.mysql.com/get/mysql57-community-release-el7-9.noarch.rpm \
	&& yum -y install mysql-server \
	&& yum -y install mysql-utilities \
	&& yum -y install mysql-connector-python \
	&& yum -y install openssh-clients \
	&& ln -s /usr/lib/python2.7/site-packages/mysql/utilities /usr/lib64/python2.7/site-packages/mysql/utilities
	&& rm -rf /var/cache/yum/* \
	&& yum clean all
