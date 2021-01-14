#FROM ubuntu:20.04
#TODO buster (because is stable) (sid worked)
#TODO odpalac jako root 
FROM debian:sid as base
LABEL maintainer="larry.marcin@gmail.com"
LABEL version="0.1"
LABEL description="PCem"
#TODO env PCem version
#TODO how to get Timezone from host?
#TODO multistage build

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Moscow 

RUN  apt-get update \
 && apt-get install -y \
 wget \
 libsdl2-dev \
 libopenal-dev \
 libwxbase3.0-dev \
 libwxgtk-media3.0-gtk3-dev \
 build-essential \
#alsa-utils \ 
 git

#cleanup
RUN apt-get clean

FROM base as pcem_build
#prepare PCEM


#RUN mkdir $HOME/.pcem/roms

RUN wget https://pcem-emulator.co.uk/files/PCemV17Linux.tar.gz
RUN mkdir PCem
RUN tar -xvf PCemV17Linux.tar.gz -C PCem
RUN rm PCemV17Linux.tar.gz
WORKDIR /PCem

RUN ./configure && make && make install
RUN useradd -ms /bin/bash pcem_user

FROM pcem_build as pcem_run

USER pcem_user
WORKDIR /home/pcem_user

RUN echo "Cloning roms repo to $HOME/.pcem/roms"
RUN git clone https://github.com/svajoklis-1/PCem-ROMs.git $HOME/.pcem/roms

#1. TODO run without x11docker
#2. mounting .local/share/x11docker/docker-pcem/.pcem/roms do kontenera jako HOME (--home)
#3 eror in x11docker ?

ENTRYPOINT ["pcem"]

