FROM centos:7

WORKDIR /tmp

RUN yum install -y mysql \
    && rm -rf /var/cache/yum/* \
    && yum clean all
    
