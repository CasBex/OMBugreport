FROM ubuntu:latest

# Install openmodelica
RUN apt-get update && apt-get install -y ca-certificates curl gnupg && curl -fsSL http://build.openmodelica.org/apt/openmodelica.asc | gpg --dearmor -o /usr/share/keyrings/openmodelica-keyring.gpg

RUN echo "deb [arch=amd64 signed-by=/usr/share/keyrings/openmodelica-keyring.gpg] \
  https://build.openmodelica.org/apt \
  $(cat /etc/os-release | grep "\(UBUNTU\\|DEBIAN\\|VERSION\)_CODENAME" | sort | cut -d= -f 2 | head -1) \
  nightly" | tee /etc/apt/sources.list.d/openmodelica.list

RUN apt-get update && apt-get install -y omc

# Install IDEAS and Buildings libraries
ADD getlibs.mos /
RUN omc getlibs.mos

# Install python
RUN apt-get update && apt-get install -y wget
ENV CONDA_DIR=/opt/conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-py310_23.5.2-0-Linux-x86_64.sh -O ~/miniconda.sh && \
     /bin/bash ~/miniconda.sh -b -p /opt/conda
ENV PATH=$CONDA_DIR/bin:$PATH
RUN conda install -c conda-forge pyfmi pandas

WORKDIR /home/ombug
ADD entrypoint.sh /home
ENTRYPOINT ["bash", "/home/entrypoint.sh"]
