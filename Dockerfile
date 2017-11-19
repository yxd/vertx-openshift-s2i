FROM openshift/base-centos7
MAINTAINER Clement Escoffier <clement@apache.org>

# Install build tools on top of base image
ENV GRADLE_VERSION 4.1
ENV MAVEN_VERSION 3.5.2

RUN yum install -y --enablerepo=centosplus \
    tar unzip bc which lsof java-1.8.0-openjdk java-1.8.0-openjdk-devel && \
    yum clean all -y && \
    (curl -0 http://www-us.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz | \
    tar -zx -C /usr/local) && \
    mv /usr/local/apache-maven-$MAVEN_VERSION /usr/local/maven && \
    ln -sf /usr/local/maven/bin/mvn /usr/local/bin/mvn && \
    curl -sL -0 https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -o /tmp/gradle-${GRADLE_VERSION}-bin.zip && \
    unzip /tmp/gradle-${GRADLE_VERSION}-bin.zip -d /usr/local/ && \
    rm /tmp/gradle-${GRADLE_VERSION}-bin.zip && \
    mv /usr/local/gradle-${GRADLE_VERSION} /usr/local/gradle && \
    ln -sf /usr/local/gradle/bin/gradle /usr/local/bin/gradle && \
    mkdir -p /opt/openshift && chmod -R a+rwX /opt/openshift &&\
    mkdir -p /opt/app-root/source && chmod -R a+rwX /opt/app-root/source && \
    mkdir -p /opt/s2i/destination && chmod -R a+rwX /opt/s2i/destination && \
    mkdir -p /opt/app-root/src && chmod -R a+rwX /opt/app-root/src && \
    mkdir -p /opt/.m2 && chmod -R a+rwX /opt/.m2

ENV PATH=/opt/maven/bin/:/opt/gradle/bin/:$PATH M2_LOCAL=/opt/.m2

ENV BUILDER_VERSION 1.0

LABEL io.k8s.description="Platform for building Vert.x applications with maven or gradle" \
      io.k8s.display-name="Vert.x 3 builder 1.0" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,maven-3,gradle-4,vert.x"

# COPY ./<builder_folder>/ /opt/openshift/
LABEL io.openshift.s2i.scripts-url=image:///usr/local/s2i
COPY ./.s2i/bin/ /usr/local/s2i

RUN chown -R 1001:1001 /opt/openshift /opt/.m2
RUN chmod -R go+rw /opt/openshift

# This default user is created in the openshift/base-centos7 image
USER 1001

# Set the default port for applications HTTP and event bus
EXPOSE 8080
EXPOSE 5701

# Set the default CMD for the image
CMD ["usage"]
