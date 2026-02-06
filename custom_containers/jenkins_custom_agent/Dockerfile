# Use the official Jenkins INBOUND AGENT base
FROM jenkins/inbound-agent:latest-jdk17

USER root

# Installation des dépendances de base
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    lsb-release \
    curl \
    unzip \
    build-essential \
    ca-certificates \
    python3 \
    python3-pip \
    python3-venv \
    git \
    docker.io \ 
    && rm -rf /var/lib/apt/lists/*

# Installation de Trivy via le script officiel (plus robuste pour Debian Trixie)
RUN curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin v0.48.3

# Install SonarScanner 5.x
RUN curl -L -o /tmp/sonar-scanner-cli.zip \
    https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip && \
    unzip /tmp/sonar-scanner-cli.zip -d /opt && \
    rm /tmp/sonar-scanner-cli.zip && \
    ln -s /opt/sonar-scanner-5.0.1.3006-linux/bin/sonar-scanner /usr/local/bin/sonar-scanner

# Set pip3 as default pip (Note: on newer Debian, you might need to use python3 -m pip)
RUN ln -sf /usr/bin/pip3 /usr/bin/pip || true

# Ajout de jenkins au groupe docker
RUN usermod -aG docker jenkins

USER jenkins