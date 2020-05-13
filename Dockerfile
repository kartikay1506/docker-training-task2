FROM centos

RUN yum install java-11-openjdk-devel -y

RUN rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key && cd /etc/yum.repos.d/ && curl -O https://pkg.jenkins.io/redhat-stable/jenkins.repo

RUN yum install jenkins -y

RUN yum install -y initscripts

RUN yum install -y yum-utils

RUN yum-config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo

RUN yum install docker-ce docker-ce-cli containerd.io --nobest -y

RUN yum install git -y

EXPOSE 8080

RUN /etc/rc.d/init.d/jenkins start

RUN echo -e "jenkins ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

CMD ["java", "-jar", "/usr/lib/jenkins/jenkins.war"]




