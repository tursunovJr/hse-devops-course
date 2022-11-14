FROM ubuntu:20.04
RUN apt-get -y upgrade
RUN apt-get update
RUN apt-get -y install cmake
RUN apt-get -y install make
RUN apt-get install -y python3 python3-pip
RUN pip3 install Flask

#install git
RUN apt-get install -y git

#create file
RUN touch /README.md

#copy local files to docker
RUN mkdir /task-docker
COPY ./task-docker /task-docker

#create executable file
RUN printf '#/bin/bash \necho Hello world' > /bin/print_hello.sh
RUN chmod +x /bin/print_hello.sh

#building cmake project
RUN cd task-docker/cmake-with-flask && cmake ./CMakeLists.txt && make

#create group and user
RUN groupadd -r devops2022 && useradd -r -g devops2022 devops2022user

#switch to user
USER devops2022user

#flask app
ENTRYPOINT ["python3", "./task-docker/cmake-with-flask/app.py", "--port=8898"]