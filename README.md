# Personal WAN2GP Web UI Docker
Privacy focused local docker environment for [WAN2GP](https://github.com/deepbeepmeep/Wan2GP) Web UI with offline mode support and easy access to files.

## Features
- Easy to install, setup and launch
- Offline mode, prevents the container from accessing the internet, while still allowing access to the webui
- Source code and data stored in your local filesystem and mounted using bind, no extra volumes

## Prerequisites

  - Cuda / Nvidia GPU
  - Linux or [Windows Subsystem for Linux](https://learn.microsoft.com/en-us/windows/wsl/install)
  - [Docker Desktop](https://www.docker.com/products/docker-desktop/) (Recommended) **or** [Docker](https://docs.docker.com/engine/install/) + [Docker Compose plugin](https://docs.docker.com/compose/install/)


## Installation

Clone or download this repository into your Linux or WSL distro.

Launch the setup script:
 ```bash
 bash setup.sh
 ```

Next, run the build script to build the docker images:
```bash
./build-docker-images.sh
```

Finally, execute the run script to complete the setup:
```bash
./run-with-internet.sh
```

Once the webui has finished downloading and you have made sure it works properly, the offline mode can be used for increased security:
```
./run-offline.sh
```

**Note that offline mode does not offer complete privacy as your browser could still leak data through javascript, see the section on [browser safety](https://github.com/LentoMan/personal-docker-docs/blob/main/browser-safety.md) in the [supplementary documentation](https://github.com/LentoMan/personal-docker-docs) for workarounds.**

Also note that some actions like the LoRA download button may require online access the first time to download all the models. 

## Usage

### Accessing the webui
The webui is accessible from your browser through:
```
http://localhost:7860/
```

## Supplementary Documentation
For additional technical documentation and setup guides, check out the [Personal Docker Docs](https://github.com/LentoMan/personal-docker-docs) repository.

## Future Plans
- Add update script (git pull)
- Add a docker compose override sample template for binding directories like models and output
