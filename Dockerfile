# Use the correct tag name verified on Docker Hub
FROM markhobson/maven-chrome:jdk-17

WORKDIR /app

# Copy the configuration file and cache dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy the rest of your project files
COPY src ./src
COPY webpage ./webpage

# Command to automatically execute the tests inside the container
CMD ["mvn", "test"]
