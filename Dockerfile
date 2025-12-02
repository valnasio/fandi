FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Atualiza e instala dependências
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    nodejs \
    npm \
    xvfb \
    x11vnc \
    fluxbox \
    novnc \
    websockify \
    python3 \
    xdg-utils \
    && apt-get clean

# Instala noVNC e websockify
RUN mkdir -p /opt/novnc && \
    cp -r /usr/share/novnc/* /opt/novnc/ && \
    ln -s /opt/novnc/vnc.html /opt/novnc/index.html

# Diretório da aplicação
WORKDIR /app

COPY package*.json ./
RUN npm install || true

COPY . .

# Expõe a porta do noVNC
EXPOSE 8080

# Comando principal
CMD bash -c "\
    Xvfb :1 -screen 0 1280x900x24 & \
    export DISPLAY=:1 && \
    fluxbox & \
    x11vnc -forever -nopw -display :1 -rfbport 5900 & \
    websockify --web=/opt/novnc 8080 localhost:5900 & \
    npm start \
"
