# FROM ghcr.io/rightnow-ai/openfang:v...
# use official image instead once available
# see: https://github.com/RightNow-AI/openfang/pull/644
# current base image has been built from source code: https://github.com/RightNow-AI/openfang/tree/v0.6.4
FROM public.ecr.aws/pergola/rightnow-ai/openfang:v0.6.4

RUN apt-get update && apt-get install -y --no-install-recommends \
    vim \
    nano \
    chromium-browser \
    && rm -rf /var/lib/apt/lists/*
