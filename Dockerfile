FROM chrisipa/debian-base:8
MAINTAINER Christoph Papke <info@papke.it>

# set environment variables
ENV SCRIPT_NAME packer-esxi
ENV ROOT_FOLDER /opt/${SCRIPT_NAME}
ENV PACKER_VERSION 1.1.0
ENV PACKER_CHECKSUM 0d6d6cd689fc22b87eb67d636c4fbf4c 
ENV PACKER_FILE_NAME packer_${PACKER_VERSION}_linux_amd64.zip
ENV PACKER_URL https://releases.hashicorp.com/packer/${PACKER_VERSION}/${PACKER_FILE_NAME}

# install additional packages
RUN apt-get install -y --no-install-recommends ssh-client sshpass

# download and install packer
RUN wget -q ${PACKER_URL} && \
    echo "${PACKER_CHECKSUM} ${PACKER_FILE_NAME}" | md5sum -c && \
    unzip -q ${PACKER_FILE_NAME} -d /usr/local/bin && \
    rm -f ${PACKER_FILE_NAME}

# add packer resources to root folder
ADD ${SCRIPT_NAME} ${ROOT_FOLDER}/${SCRIPT_NAME}
ADD templates ${ROOT_FOLDER}/templates

# update alternatives
RUN update-alternatives --install "/usr/bin/${SCRIPT_NAME}" "${SCRIPT_NAME}" "${ROOT_FOLDER}/${SCRIPT_NAME}" 1 && \
    update-alternatives --set "${SCRIPT_NAME}" "${ROOT_FOLDER}/${SCRIPT_NAME}"

# set workdir
WORKDIR ${ROOT_FOLDER}

# specify entrypoint
ENTRYPOINT ["packer-esxi"]
