FROM adoptopenjdk/openjdk8:centos-jre

RUN yum update -y
RUN yum install -y \
	curl wget \
	git \
	rsync \
	nano \
	zip
		
EXPOSE 25565

RUN git clone https://github.com/Fryro/Minecraft.git

RUN cp Minecraft/* .

RUN cat ./setup-mc-server.sh
CMD ./setup-mc-server.sh container
