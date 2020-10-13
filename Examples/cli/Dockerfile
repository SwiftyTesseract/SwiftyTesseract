FROM swiftlang/swift:5.3-focal

RUN apt-get update && \
    apt-get install -yq libtesseract-dev libleptonica-dev && \
    mkdir -p /usr/src/swiftytesseract

WORKDIR /usr/src/cli
COPY . .

RUN swift build -c release
ENV PATH $PATH:/usr/src/cli/.build/release
