# Use a more recent Ubuntu base image
FROM ubuntu:20.04
LABEL maintainer="2597892@dundee.ac.uk"
# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive
# Install necessary packages
RUN apt-get update && apt-get install -y \
    git \
    gcc \
    make \
    libpcre3-dev \
    libssl-dev \
    zlib1g-dev \
    wget \
    && rm -rf /var/lib/apt/lists/*
# Download and compile NGINX with the RTMP module
RUN git clone https://github.com/arut/nginx-rtmp-module.git /tmp/nginx-rtmp-module \
    && mkdir -p /tmp/nginx \
    && cd /tmp/nginx \
    && wget http://nginx.org/download/nginx-1.21.6.tar.gz \
    && tar zxpvf nginx-1.21.6.tar.gz \
    && cd nginx-1.21.6 \
    && ./configure --add-module=/tmp/nginx-rtmp-module/ --with-http_ssl_module --prefix=/usr/local/nginx-streaming/ \
    && make \
    && make install
# Clean up the build directory
RUN rm -rf /tmp/nginx-rtmp-module /tmp/nginx
# Set up directories
RUN mkdir -p /var/www/html \
    && mkdir -p /var/nginx-streaming \
    && mkdir -p /var/log/nginx
#copy video files
COPY www/html/videos /usr/share/nginx/html/videos
# Copy your custom NGINX config into the container
COPY nginx/nginx.conf /usr/local/nginx-streaming/conf/nginx.conf
# Expose the necessary ports
EXPOSE 80
EXPOSE 1935
# Use the "exec" form of CMD to help NGINX shut down gracefully on SIGTERM (i.e., `docker stop`)
CMD ["/usr/local/nginx-streaming/sbin/nginx", "-g", "daemon off;"]
