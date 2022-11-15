FROM ubuntu:20.04
RUN apt-get -y upgrade
RUN apt-get update
RUN apt-get -y install cmake
RUN apt-get -y install make
RUN apt-get install -y python3 python3-pip
RUN pip3 install Flask

WORKDIR /bin

#install git
RUN apt-get install -y git

#create file
RUN touch /README.md

# #copy local files to docker
RUN mkdir /task-docker
COPY ./ /bin

#create executable file
RUN printf '#!/bin/bash \necho Hello world' > /bin/print_hello
RUN chmod +x /bin/print_hello

#building cmake project
RUN cmake ./CMakeLists.txt && make

#create group and user
RUN groupadd -r devops2022 && useradd -r -g devops2022 devops2022user

#switch to user
USER devops2022user

#flask app
EXPOSE 8898
ENTRYPOINT ["python3", "./app.py", "--host=0.0.0.0", "--port=8898"]
