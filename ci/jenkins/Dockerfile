FROM jenkins/jenkins:lts-jdk21

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

COPY casc.yaml /usr/local/jenkins-casc/casc.yaml
ENV CASC_JENKINS_CONFIG=/usr/local/jenkins-casc/casc.yaml
