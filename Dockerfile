# Sample Dockerfile with AlertLogic Universal Agent
FROM centos:latest

###################################
# update system packages
###################################
RUN yum update -y && yum install -y wget

################################
# install the alertlogic agent
################################
RUN mkdir /downloads && \
    wget https://scc.alertlogic.net/software/al-agent-LATEST-1.x86_64.rpm -O /downloads/al-agent_LATEST_amd64.rpm && \
    rpm -U /downloads/al-agent_LATEST_amd64.rpm

################################
# prepare entry point
COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
VOLUME /var/alertlogic/etc
################################
