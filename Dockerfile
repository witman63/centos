# Centos 7 based container <hier je verdere omschrijving>
FROM hub.rinis.cloud/library/centos7:latest
MAINTAINER <hier je naam>

# User en group vars
ENV USER=<hier de groep b.v. dias>
ENV USERID=<hier de groep id b.v. 555>
ENV GROUP=<hier de groep b.v. connect>
ENV GROUPID=<hier de groep id b.v. 555>

# Add user and group to run application 
RUN groupadd -g ${GROUPID} ${GROUP} && \
 adduser -u ${USERID} -g ${GROUPID} ${USER} 

# Add docker entrypoint
ADD docker-entrypoint.sh /

# hieronder je eigen configuratie 
# ...
# ...
# ...
# ...



# Set user and workdir
USER ${USERID}
WORKDIR /opt/my-app

# Set entrypoint
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["my-app"]