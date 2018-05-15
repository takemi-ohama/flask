FROM ubuntu:bionic

LABEL maintainer="takemi.ohama@gmail.com"

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get -yq dist-upgrade \
 && apt-get install -yq --no-install-recommends \
    git wget curl libreadline-dev  bzip2 vim ca-certificates \
    sudo locales fonts-liberation libxrender1 mysql-client \
    language-pack-ja-base language-pack-ja fonts-mplus ssh \
    graphviz gcc python-pip \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN sed -i -e "s/# ja_JP.UTF-8 UTF-8/ja_JP.UTF-8 UTF-8/" /etc/locale.gen
RUN locale-gen
RUN update-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja"
ENV LANG=ja_JP.UTF-8

# Configure environment
ENV CONDA_DIR /var/lib/conda
ENV CONDA_VERSION /var/lib/conda
ENV PATH $CONDA_DIR/bin:$PATH
ENV SHELL /bin/bash
ENV LC_ALL ja_JP.UTF-8
ENV LANG ja_JP.UTF-8
ENV LANGUAGE ja_JP.UTF-8

RUN useradd -m -s /bin/bash docker && \
    usermod -G users docker && \
    usermod -G users root && \
    echo '%users ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    mkdir /home/docker/.ssh && chown docker.docker /home/docker/.ssh

RUN mkdir /var/run/sshd
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN echo "export VISIBLE=now" >> /etc/profile

RUN cd /tmp && \
    mkdir -p $CONDA_DIR && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    /bin/bash Miniconda3-latest-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
    rm Miniconda3-latest-Linux-x86_64.sh && \
    ln -s $CONDA_DIR/bin/conda /usr/bin/conda

RUN conda install --quiet --yes conda && \
    conda config --system --add channels conda-forge

RUN conda install --quiet --yes \
    'conda-build' \
    'readline' \
    'cython' \
    'mysql-connector-python' \
    'pymysql' \
    'gensim' \
    'xgboost' \
    'tensorflow' \
    'imbalanced-learn' \
    'flask' \
    && conda clean -tipsy

RUN pip install --upgrade pip && \
    pip install awscli && \
    pip install --upgrade awscli && \
    echo "complete -C aws_completer aws" >> /etc/profile

USER docker

EXPOSE 5000
ENTRYPOINT ["tail","-f","/dev/null"]
#ENTRYPOINT ["python", "/src/app.py"]
