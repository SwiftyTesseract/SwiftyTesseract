FROM ubuntu:20.04

RUN DEBIAN_FRONTEND=noninteractive && \
    apt-get update -yq && \
    apt-get install -yq curl libtesseract-dev libleptonica-dev && \
    curl -s https://packagecloud.io/install/repositories/swift-arm/release/script.deb.sh | bash && \
    apt-get install -yq swiftlang