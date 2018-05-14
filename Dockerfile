FROM ubuntu:bionic

LABEL maintainer="takemi.ohama@gmail.com"

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get -yq dist-upgrade \
 && apt-get install -yq --no-install-recommends \
    wget curl libreadline-dev  bzip2 vim ca-certificates \
    sudo locales fonts-liberation libxrender1 mysql-client\
    language-pack-ja-base language-pack-ja fonts-mplus \
    libav-tools graphviz  
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN sed -i -e "s/# ja_JP.UTF-8 UTF-8/ja_JP.UTF-8 UTF-8/" /etc/locale.gen
RUN locale-gen
RUN update-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja"  
ENV LANG=ja_JP.UTF-8 

RUN pip install --upgrade pip && \
    pip install awscli && \
    pip install --upgrade awscli && \ 
    echo "complete -C aws_completer aws" >> /etc/profile

ENV CONDA_DIR=/opt/conda \
    SHELL=/bin/bash \
    NB_USER=docker \
    NB_UID=1000 \
    NB_GID=100 \
    LC_ALL=ja_JP.UTF-8 \
    LANG=ja_JP.UTF-8 \
    LANGUAGE=ja_JP.UTF-8
ENV PATH=$CONDA_DIR/bin:$PATH \
    HOME=/home/$NB_USER

RUN useradd -m -s /bin/bash docker && \
    usermod -G users docker && \
    usermod -G users root && \
    echo '%users ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    mkdir /home/docker/.ssh && chown docker.docker /home/docker/.ssh

ENV VISIBLE=now 

RUN mkdir /var/run/sshd && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    echo "export VISIBLE=now" >> /etc/profile && \
    echo "export TERM=xterm" >> /etc/profile && 


USER $NB_UID

ENV MINICONDA_VERSION 4.4.10
RUN cd /tmp && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && \
    echo "bec6203dbb2f53011e974e9bf4d46e93 *Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh" | md5sum -c - && \
    /bin/bash Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
    rm Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && \
    $CONDA_DIR/bin/conda config --system --prepend channels conda-forge && \
    $CONDA_DIR/bin/conda config --system --set auto_update_conda false && \
    $CONDA_DIR/bin/conda config --system --set show_channel_urls true && \
    $CONDA_DIR/bin/conda update --all --quiet --yes
    
RUN conda install --quiet --yes \
    'conda-build' \
    'readline' \
    'mysql-connector-python' \
    'pymysql' \
    'gensim' \ 
    'xgboost' \
    'tensorflow' \
    'imbalanced-learn' \
    'flask'
    && conda clean -tipsy


EXPOSE 5000
ENTRYPOINT ["tail","-f","/dev/null"]
#ENTRYPOINT ["python", "/src/app.py"]



