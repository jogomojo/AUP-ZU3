## Build PYNQ SD Image for AUP-ZU3

### Prerequisites

**Required tools:**

* Ubuntu 24.04 LTS 64-bit host PC
* Passwordless SUDO privilege for the building user
* Roughly 35GB of free space (build process only, not accounting for AMD tools)
* At least 8GB of RAM (more is better)
* AMD Vivado and Vitis 2025.2. Boot artefacts are built with EDF, not PetaLinux.

Retrieve the AUP-ZU3 board git into a NEW directory.

```shell
git clone https://github.com/Xilinx/AUP-ZU3.git <LOCAL_AUP-ZU3_REPO>
cd <LOCAL_AUP-ZU3_REPO> && git submodule init && git submodule update
```

### Build SD Image

The full details on the SD Image build process can be found on the [PYNQ website](https://pynq.readthedocs.io/en/latest/pynq_sd_card.html)

PYNQ is a submodule and it points to the corresponding branch.

Configure and install build tools, this will take some effort and will be an iterative process. Install on your own any missing tools.

Inside the `<LOCAL_AUP-ZU3_REPO>/` execute

```shell
cd pynq/sdbuild
make checkenv
```

The AUP-ZU3 comes in two configurations: 4GB and 8GB DDR4. Each board is marked 4G or 8G. The default is 4GB.

```shell
make image-4gb 2>&1 | tee build.log
```

OR

```shell
make image-8gb 2>&1 | tee build.log
```

`make` builds the 4GB classic image. To build a [PYNQ.remote](https://pynq.readthedocs.io/en/latest/pynq_remote.html) image, use `pynqremote-4gb` or `pynqremote-8gb`.

Once the build has completed, the image is `<LOCAL_AUP-ZU3_REPO>/pynq/sdbuild/output/AUP-ZU3-4.0.0.img` for a classic image, or `AUP-ZU3-4.0.0-remote.img` for a remote image.

To write the image to an SD card follow the steps in [PYNQ SD card documentation](https://pynq.readthedocs.io/en/latest/appendix/sdcard.html)

Use [balenaEtcher](https://etcher.balena.io), [Win32DiskImager](https://win32diskimager.org), or directly through the Operating System to write this image to an SD card.

---------------------------------------
<p class="copyright">Copyright&copy; 2025 Advanced Micro Devices</p>
