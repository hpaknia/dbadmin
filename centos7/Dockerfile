FROM centos:7

WORKDIR /tmp

RUN yum -y update \
    && rm -rf /var/cache/yum/* \
    && yum clean all

RUN rpm -Uvh http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm \
    && yum install -y mysql-community-client mysql-connector-python  mysql-utilities mysql-utilities-extra \
    && ln -s /usr/lib/python2.7/site-packages/mysql/utilities /usr/lib64/python2.7/site-packages/mysql/utilities \
    && rm -rf /var/cache/yum/* \
    && yum clean all
    
