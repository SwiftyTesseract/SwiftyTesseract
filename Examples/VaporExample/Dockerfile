# ================================
# Build image
# ================================
FROM swiftlang/swift:nightly-focal as build
WORKDIR /build

RUN apt-get update && \
    apt-get install -yq libtesseract-dev libleptonica-dev && \
    mkdir -p /usr/src/swiftytesseract

# First just resolve dependencies.
# This creates a cached layer that can be reused
# as long as your Package.swift/Package.resolved
# files do not change.
COPY ./Package.* ./
RUN swift package resolve

# Copy entire repo into container
COPY . .

# Compile with optimizations
RUN swift build --enable-test-discovery -c release

# ================================
# Run image
# ================================
FROM swiftlang/swift:nightly-focal

RUN apt-get update && \
    apt-get install -yq libtesseract-dev libleptonica-dev && \
    mkdir -p /usr/src/swiftytesseract

# Create a vapor user and group with /app as its home directory
RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /app vapor

# Switch to the new home directory
WORKDIR /app

# Copy build artifacts
COPY --from=build --chown=vapor:vapor /build/.build/release /app
# Uncomment the next line if you need to load resources from the `Public` directory
#COPY --from=build --chown=vapor:vapor /build/Public /app/Public

# Ensure all further commands run as the vapor user
USER vapor:vapor

# Let Docker bind to port 8080
EXPOSE 8080

# Start the Vapor service when the image is run, default to listening on 8080 in production environment 
ENTRYPOINT ["./Run"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]
