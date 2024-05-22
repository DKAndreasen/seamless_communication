FROM  pytorch/pytorch:2.0.1-cuda11.7-cudnn8-runtime

# Install base utilities
RUN apt-get update \
    && apt-get install -y build-essential \
    && apt-get install -y wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY README.md setup.py /app/ 
COPY ./src /app/src

# for the install we move the requirements to the docker file to have control
# We need to specify the extra-index-url as suggested at https://github.com/facebookresearch/fairseq2#Variants
# to avoid pip upgrading to the latest pytorch and in doing so breaking some dependencies. We specify PT2.0.1 and 
# cuda 11.7 since that it the image we take off from  
RUN pip install datasets==2.18.0 \
    && pip install --extra-index-url https://fair.pkg.atmeta.com/fairseq2/whl/pt2.0.1/cu117 fairseq2==0.2.* \
    && pip install fire \
    && pip install librosa \
    && pip install openai-whisper \
    && pip install simuleval~=1.1.3 \
    && pip install sonar-space==0.2.* \
    && pip install soundfile \
    && pip install scipy \
    && pip install torchaudio \
    && pip install tqdm \
    && pip install . \
#    && pip install fairseq2 \ # Already installed through the setup file
    && pip install pydub sentencepiece \
    && pip install jupyterlab \
    && conda install -y -c conda-forge libsndfile \
    && pip install matplotlib \
# to test transformers implementation of SeamlessM4T
    && pip install transformers \
    && pip install protobuf


# Set where models and other assets should be stored in the container
ENV XDG_CACHE_HOME=/app/.cache
RUN mkdir -p ${XDG_CACHE_HOME}

# Change the token in the docker-compose or override when setting up (building) in order 
# to have a somewhat secure jupyter server
ENV JUPYTER_TOKEN=passwd

# start jupyter lab
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--allow-root", "--no-browser"]
EXPOSE 8888