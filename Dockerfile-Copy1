#######################################################################
# Stage 1 — download the model once during docker build               #
#######################################################################
FROM ollama/ollama:0.2.8 AS model-puller

# Put the cache in a path that’s easy to copy out
ENV OLLAMA_MODELS=/models
RUN ollama serve & \
    sleep 6 && \
    ollama pull mistral:7b && \
    pkill -SIGTERM ollama

#######################################################################
# Stage 2 — final runtime image                                       #
#######################################################################
FROM ollama/ollama:0.2.8 AS runtime

# Copy the pre-pulled model into Ollama’s default cache directory
COPY --from=model-puller /models /root/.ollama/models
ENV OLLAMA_MODELS=/root/.ollama/models

#--------------------------------------------------
# Debian/Ubuntu package setup (kept from your file)
#--------------------------------------------------
RUN apt-get update -y -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends \
        software-properties-common gpg-agent build-essential apt-utils \
        python3 python3-pip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ENV PYTHONUNBUFFERED=1
RUN pip install --upgrade pip && pip install runpod

# Copy the rest of your source into the image
WORKDIR /
COPY . .

#--------------------------------------------------
# Start Ollama + your RunPod handler
#--------------------------------------------------
# If start.sh launches both processes, keep it:
ENTRYPOINT ["bash", "start.sh"]

# If you only want the model running (no handler), uncomment instead:
# CMD ["ollama", "serve", "--addr", "0.0.0.0:11434"]

# For completeness, expose Ollama’s port
EXPOSE 11434