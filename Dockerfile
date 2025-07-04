#######################################################################
# Stage 1 – pull the model once at build-time                         #
#######################################################################
FROM ollama/ollama:0.9.2 AS model-puller

ENV OLLAMA_MODELS=/models
#RUN mkdir -p $OLLAMA_MODELS && \
RUN ollama serve & \
    sleep 6 && \
    ollama pull leeplenty/lumimaid-v0.2:8b && \
    pkill -SIGTERM ollama
#######################################################################
# Stage 2 – runtime image (GPU-ready, Flash-Attn on)                  #
#######################################################################
FROM ollama/ollama:0.9.2 AS runtime

# copy pre-pulled cache
COPY --from=model-puller /models /root/.ollama/models
ENV  OLLAMA_MODELS=/root/.ollama/models
ENV  OLLAMA_FLASH_ATTENTION=1

# ------- your Python deps / handler --------
RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
        python3 python3-pip python-is-python3 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
RUN pip install --upgrade pip runpod

WORKDIR /
COPY . .

ENTRYPOINT ["bash", "start.sh"]
EXPOSE 11434
