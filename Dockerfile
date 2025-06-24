#######################################################################
# Stage 1 – pull the quantised model once at build-time               #
#######################################################################
FROM ollama/ollama:cuda-0.2.12 AS model-puller

ENV OLLAMA_MODELS=/models
RUN mkdir -p $OLLAMA_MODELS && \
    ollama serve & sleep 6 && \
    ollama pull mistral:7b-q4_K_M && \
    pkill -SIGTERM ollama

#######################################################################
# Stage 2 – runtime image, Flash-Attn & GPU ready                     #
#######################################################################
FROM ollama/ollama:cuda-0.2.12 AS runtime

# copy model cache
COPY --from=model-puller /models /root/.ollama/models
ENV  OLLAMA_MODELS=/root/.ollama/models
ENV  OLLAMA_FLASH_ATTENTION=1        # GPU kernels
# ENV OLLAMA_NUM_THREAD=$(nproc)     # uncomment for CPU workers

# ----- (your Python deps + handler) ---------------------------------
RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
        python3 python3-pip python-is-python3 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
RUN pip install --upgrade pip runpod

WORKDIR /
COPY . .

ENTRYPOINT ["bash", "start.sh"]      # starts both Ollama & handler
EXPOSE 11434