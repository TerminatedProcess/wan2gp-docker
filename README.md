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

**Note that offline mode does not offer complete privacy and your browser may still leak data through javascript, see the [browser safety section](#browser-safety) for potential workarounds.**

Also note that some actions like **interrogate clip** may require online access the first time to download all the models and other requirements. 

Installing and updating extensions will naturally also require launching with internet:
```bash
./run-with-internet.sh
```

## Usage

### Accessing the webui
The webui is accessible from your browser through:
```
http://localhost:7860/
```

### Browser safety
Depending on the server configuration, your browser may still leak data through javascript, an easy fix is to use Firefox with the `Work Offline` option. After starting Firefox, press `Alt` or `F10`, then select `Work Offline` from the file menu. You will still be able to access localhost but there should be no external internet access. You may also want to open developer mode with `F12` to monitor the **Console** and **Network** tabs for potential issues when working offline. Some remote dependencies may be loaded from content delivery networks, but can often be cached before working offline.

When using offline mode, you may run into browser issues with things like dropdowns not updating with latest added models etc., consider turning off disk cache or clearing browser cache if that happens. It may be a good idea to create a separate Firefox profile without disk cache which always starts in offline mode.

To create a separate profile, if using Windows, place a shortcut to Firefox on your desktop or duplicate the existing shortcut, rename the copy to `altprofile`. Right click the `altprofile` shortcut and open the properties, change the target to something like:
```
"C:\Program Files\Mozilla Firefox\firefox.exe" -profile "E:\altprofile" -no-remote -offline
```

The `-no-remote` option is important, it allows you to use multiple profiles like your **default profile** and your **altprofile** independently at the same time in different windows. Launch the **altprofile** shortcut and make sure it starts offline. You may now also want to disable any diagnostics, telemetry and crash reports in the Firefox security settings for your alternative profile.

The new profile should be hidden from the profilemanager, but in case your default firefox profile no longer opens as default, open the profilemanager and set it as default without asking using:
```
"C:\Program Files\Mozilla Firefox\firefox.exe" -profilemanager
```

**Do not delete any profiles in the profilemanager as it may delete your default profile along with the actual profile you wanted to delete.**

To turn of disk cache, enter `about:config` in the url bar and accept the risk. Next, search for `browser.cache.disk.enable` and toggle it to false. To verify that the setting is applied, enter `about:cache` in the url bar. The **Storage disk location** should now say "**none, only stored in memory**".

Some alternative options to explore could be using a firewall or configuring a proxy for your browser.


## Future Plans

- Add update script (git pull)
- Add template for binding directories like models and output
- Shadow mode for more privacy when updating webui with internet connection
- Add read only protection for webui source code directories
- Support for other GPUs

- Create a WSL and Docker Desktop setup guide

## Technical Overview

### Offline mode

In offline mode, the webui container is only allowed to communicate with other containers inside a docker internal network. An additional "tunnel" container is created which has access to both the external and internal docker networks. The tunnel simply listens to the port where the webui would normally reside on the external network and forwards the traffic to the webui container on the internal network.

When running in offline mode, a communication attempt with the outside world is performed during startup. The webui container tries to ping the Google DNS server at 8.8.8.8, which should never succeed in this mode. If it does succeed, the webui container simply aborts the launch.

### Bind mounts

The external webui directory is mounted into the container with a bind mount, this means you can easily access and modify all source code and data from outside the container. 

To make sure files and directories created inside the container gets the proper external user id, the id of your external user is set in the `user.env` file as the `setup.sh` script runs. Your external user id is then read from the `user.env` during container startup and set for the `ubuntu` user inside the container.

The users home directory is mounted into the `<webui>/cache/home` of the repo and tmpdir is mounted into `<webui>/tmp` of the repo.
