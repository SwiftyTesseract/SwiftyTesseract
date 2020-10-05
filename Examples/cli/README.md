# CLI Example

To run the example using SPM, invoke the following on the command line:
```bash
swift run recognize-text image_sample.jpg
```

A Dockerfile is provided for running the example in a Linux environment. 

Build the image:
```bash
docker build -t tesseract-cli-example .
```
Run the container in interactive mode:
```bash
docker run -it tesseract-cli-example bash
```

Run the CLI in the container:
```bash
root@911756319c29:/usr/src/cli$ recognize-text image_sample.jpg
```