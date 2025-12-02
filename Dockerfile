FROM debian:stable

# Atualiza sistema
RUN apt-get update && apt-get install -y \
    wget git curl nano \
    xvfb x11vnc fluxbox \
    novnc websockify \
    xdg-utils \
    libgtk-3-0 libx11-xcb1 libnss3 libasound2 \
    libgbm1 libxshmfence1 libatk1.0-0 libatk-bridge2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Instalar Node.js LTS
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# Copia seu código Electron
WORKDIR /app
COPY . /app

# Instala dependências do Electron
RUN npm install

# Porta do noVNC
EXPOSE 8080

# Script de inicialização
CMD bash -c "\
    Xvfb :1 -screen 0 1280x900x24 & \
    export DISPLAY=:1 && \
    fluxbox & \
    websockify --web=/usr/share/novnc/ 8080 localhost:5900 & \
    x11vnc -forever -usepw -create & \
    npm start \
"
