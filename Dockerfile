FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

# Copy the build config first so Maven can cache dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source and compile
COPY src ./src
RUN mvn test-compile -B

FROM eclipse-temurin:17-jre-jammy AS runtime
WORKDIR /app

# Install browser dependencies and Google Chrome (stable)
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    curl \
    unzip \
    libglib2.0-0 \
    libnss3 \
    libgconf-2-4 \
    libfontconfig1 \
    ca-certificates \
    fonts-liberation \
    && rm -rf /var/lib/apt/lists/* \
    && curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-linux-signing-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-linux-signing-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# Copy only the built app from the build stage
COPY --from=build /app /app

ENV CHROME_BIN=/usr/bin/google-chrome-stable

# Command to run the TestNG tests inside the container
CMD ["mvn", "test"]

# Install stable Chrome dependencies required for headless Selenium runs
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    curl \
    unzip \
    libglib2.0-0 \
    libnss3 \
    libgconf-2-4 \
    libfontconfig1 \
    chromium \
    && rm -rf /var/lib/apt/lists/*

# Copy compiled classes and dependencies from the build stage
COPY --from=build /app /app

# Set environment variable to target the internal Chromium binary if needed
ENV CHROME_BIN=/usr/bin/chromium

# Default command to run the TestNG tests inside the container
CMD ["mvn", "test"]
