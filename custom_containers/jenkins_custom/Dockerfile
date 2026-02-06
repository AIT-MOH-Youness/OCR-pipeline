# Use official Jenkins LTS image with Java 17
FROM jenkins/jenkins:lts-jdk17

USER root

# Install essentials: Python 3, pip, venv, git, Docker CLI, unzip, curl, etc.
RUN apt-get update && \
    apt-get install -y \
        python3 \
        python3-pip \
        python3-venv \
        git \
        docker.io \
        curl \
        unzip \
        build-essential \
        ca-certificates \
        gnupg \
        lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Install SonarScanner 5.x (compatible Java 17)
RUN curl -L -o /tmp/sonar-scanner-cli.zip \
    https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip && \
    unzip /tmp/sonar-scanner-cli.zip -d /opt && \
    rm /tmp/sonar-scanner-cli.zip && \
    ln -s /opt/sonar-scanner-5.0.1.3006-linux/bin/sonar-scanner /usr/local/bin/sonar-scanner

# Add Jenkins user to Docker group
RUN usermod -aG docker jenkins

# Set pip3 as default pip
RUN update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

# Switch back to Jenkins user
USER jenkins

# Verify versions (optional)
# RUN java -version && python3 --version && pip --version && docker --version && sonar-scanner --version
