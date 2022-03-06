FROM fedora:35

ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}

EXPOSE 8888

RUN \
  dnf -y makecache && \
  dnf -y upgrade  && \
  dnf -y install gcc gcc-c++ gcc-gfortran autoconf automake cmake git

RUN \
  curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
  /bin/sh ./Miniconda3-latest-Linux-x86_64.sh -p /opt/mc3 -b && \
  ln -s /opt/mc3/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
  . /opt/mc3/etc/profile.d/conda.sh && \
  conda activate base && \
  conda install -y -c conda-forge mamba

COPY environment.yml /tmp/environment.yml

RUN \
  . /etc/profile.d/conda.sh && \
  mamba env create -n gt4py -f /tmp/environment.yml

RUN \
  /usr/sbin/useradd -m -u ${NB_UID} ${NB_USER}

COPY demo_burgers.ipynb $HOME

RUN /usr/bin/chown -R jovyan ${HOME}

USER jovyan
WORKDIR $HOME

ENV PATH /opt/mc3/envs/gt4py/bin:$PATH
ENV CONDA_DEFAULT_ENV gt4py

CMD ["jupyter","lab","--ip=0.0.0.0","--port=8888"]
  
