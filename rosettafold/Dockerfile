FROM nvidia/cuda:11.1-cudnn8-runtime-ubuntu18.04

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
      build-essential \
      wget \
      && rm -rf /var/lib/apt/lists/*

RUN wget -q -P /tmp \
  https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && bash /tmp/Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda \
    && rm /tmp/Miniconda3-latest-Linux-x86_64.sh


COPY RoseTTAFold-linux.yml .

ENV PATH="/opt/conda/bin:$PATH"
RUN conda env create -f RoseTTAFold-linux.yml

COPY install_dependencies.sh .
RUN ./install_dependencies.sh


WORKDIR /
COPY . .
RUN chmod +x run.sh
ENTRYPOINT ["/run.sh"]
