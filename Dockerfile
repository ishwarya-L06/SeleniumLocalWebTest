# Use an image that already has Chrome, Maven, and Java pre-configured
FROM markhobson/maven-chrome:3.9.6-openjdk-17

WORKDIR /app

# Copy the configuration file and cache dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy the rest of your project files
COPY src ./src
COPY webpage ./webpage

# Command to automatically execute the tests inside the container
CMD ["mvn", "test"]
