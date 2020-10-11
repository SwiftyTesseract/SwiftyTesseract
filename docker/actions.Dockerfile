FROM swiftlang/swift:nightly-focal

RUN apt-get update && \
    apt-get install -yq libtesseract-dev libleptonica-dev && \
    mkdir -p /usr/src/swiftytesseract

WORKDIR /usr/src/swiftytesseract
COPY . .

RUN swift test