ARG base=nvidia/cuda:11.6.2-cudnn8-runtime-ubuntu20.04

FROM ${base}

ENV DEBIAN_FRONTEND=noninteractive LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
ENV PATH /opt/conda/bin:$PATH

ARG MOSEC_PORT=8080
ENV MOSEC_PORT=${MOSEC_PORT}

ARG CONDA_VERSION=py310_23.1.0-1

RUN apt update && \
    apt install -y --no-install-recommends \
    wget \
    git \
    python3 \
    python3-pip \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# upgrade pip
RUN python3 -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --upgrade pip
# update the pip source
RUN pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

# RUN set -x && \
#     UNAME_M="$(uname -m)" && \
#     if [ "${UNAME_M}" = "x86_64" ]; then \
#     MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh"; \
#     SHA256SUM="00938c3534750a0e4069499baf8f4e6dc1c2e471c86a59caa0dd03f4a9269db6"; \
#     elif [ "${UNAME_M}" = "s390x" ]; then \
#     MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-s390x.sh"; \
#     SHA256SUM="a150511e7fd19d07b770f278fb5dd2df4bc24a8f55f06d6274774f209a36c766"; \
#     elif [ "${UNAME_M}" = "aarch64" ]; then \
#     MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-aarch64.sh"; \
#     SHA256SUM="48a96df9ff56f7421b6dd7f9f71d548023847ba918c3826059918c08326c2017"; \
#     elif [ "${UNAME_M}" = "ppc64le" ]; then \
#     MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-ppc64le.sh"; \
#     SHA256SUM="4c86c3383bb27b44f7059336c3a46c34922df42824577b93eadecefbf7423836"; \
#     fi && \
#     wget "${MINICONDA_URL}" -O miniconda.sh -q && \
#     echo "${SHA256SUM} miniconda.sh" > shasum && \
#     if [ "${CONDA_VERSION}" != "latest" ]; then sha256sum --check --status shasum; fi && \
#     mkdir -p /opt && \
#     bash miniconda.sh -b -p /opt/conda && \
#     rm miniconda.sh shasum && \
#     ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
#     echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
#     echo "conda activate base" >> ~/.bashrc && \
#     find /opt/conda/ -follow -type f -name '*.a' -delete && \
#     find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
#     /opt/conda/bin/conda clean -afy

# COPY Miniconda3-py310_23.1.0-1-Linux-x86_64.sh /

# RUN bash Miniconda3-py310_23.1.0-1-Linux-x86_64.sh -b -p /opt/conda

# COPY .condarc /home/

# RUN conda create -n mist python=3.10

# ENV MIST_PREFIX=/opt/conda/envs/mist/bin

# RUN update-alternatives --install /usr/bin/python python ${MIST_PREFIX}/python 1 && \
#     update-alternatives --install /usr/bin/python3 python3 ${MIST_PREFIX}/python3 1 && \
#     update-alternatives --install /usr/bin/pip pip ${MIST_PREFIX}/pip 1 && \
#     update-alternatives --install /usr/bin/pip3 pip3 ${MIST_PREFIX}/pip3 1

RUN pip3 install torch==1.13.1+cu116 torchvision==0.14.1+cu116 torchaudio==0.13.1 --extra-index-url https://download.pytorch.org/whl/cu116
RUN pip3 install numpy albumentations==0.4.3 diffusers opencv-python pudb==2019.2 
RUN pip3 install invisible-watermark imageio==2.9.0 imageio-ffmpeg==0.4.2 pytorch-lightning==1.4.2
RUN pip3 install omegaconf==2.1.1 test-tube>=0.7.5 einops==0.3.0 torch-fidelity==0.3.0 
RUN pip3 install transformers==4.19.2 torchmetrics==0.6.0 kornia==0.6 gradio

RUN pip3 install -e git+https://ghproxy.com/https://github.com/CompVis/taming-transformers.git@master#egg=taming-transformers

RUN pip3 install -e git+https://ghproxy.com/https://github.com/openai/CLIP.git@main#egg=clip

RUN pip3 install advertorch@git+https://ghproxy.com/https://github.com/BorealisAI/advertorch.git


# COPY requirements.txt /

# RUN pip install -r requirements.txt

# RUN mkdir -p /workspace

# COPY main.py workspace/

# WORKDIR workspace

# RUN python main.py --dry-run

# # disable huggingface update check (could be very slow)
# ENV HF_HUB_OFFLINE=true


RUN mkdir -p /workspace

WORKDIR /workspace

RUN git clone -b deploy-on-flows --single-branch https://ghproxy.com/https://github.com/apepkuss/mist.git

WORKDIR /workspace/mist

RUN python3 mist_v2_dryrun.py 16 100 512 1 2 1

ENTRYPOINT [ "python3", "mist_v2_main.py" ]
CMD [ "--timeout", "20000" ]