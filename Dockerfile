FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

# Copy the build config first so Maven can cache dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source and compile
COPY src ./src
RUN mvn test-compile -B

FROM maven:3.9.6-eclipse-temurin-17 AS runtime
WORKDIR /app

# Install browser dependencies and official Google Chrome Stable cleanly
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    curl \
    unzip \
    libglib2.0-0 \
    libnss3 \
    libfontconfig1 \
    ca-certificates \
    fonts-liberation \
    && rm -rf /var/lib/apt/lists/* \
    && curl -fsSL https://google.com | gpg --dearmor -o /usr/share/keyrings/google-linux-signing-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-linux-signing-keyring.gpg] http://google.com stable main" > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# Copy only the built app from the build stage
COPY --from=build /app /app
COPY --from=build /root/.m2 /root/.m2

ENV CHROME_BIN=/usr/bin/google-chrome-stable

# Command to execute tests smoothly
CMD ["mvn", "test"]
