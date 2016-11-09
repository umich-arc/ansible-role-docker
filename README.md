# Ansible Role: Docker

This role manages the install and configuration of the Docker Engine with support for credential management and custom storage provisioning. It has been tested with CentOS 7.2, Debian Jessie, Ubuntu Trusty, and Ubuntu Xenial.



# Index
----------

* [Requirements](#requirements)
* [Dependencies](#dependencies)
* [Role Variables](#role-variables)
  * [Execution Control](#execution-control)
  * [Docker-py](#docker-py)
  * [Docker Engine Repository](#docker-engine-repository)
  * [Docker Engine Storage Configuration](#docker-engine-storage-configuration)
  * [Docker Engine](#docker-engine)
  * [Docker Engine Users and Groups](#docker-engine-users-and-groups)
  * [Docker Engine Registry Credentials](#docker-engine-registry-credentials)
  * [Container Networks](#container-networks)
  * [Container Images](#container-images)
  * [Container Execution](#container-execution)
* [Example Playbook](#example-playbook)
* [Testing and Contributing](#testing-and-contributing)
* [License](#license)
* [Author Information](#author-information)


Requirements
------------
This role depends on Ansible 2.1 or greater for full functionality.
If using the role to manage Docker Networks version 2.2 or higher is required and the network section in `tasks/main.yml` should be uncommented. It will become uncommented by default once Ansible 2.2 becomes more ubiquitous.



Dependencies
------------

The python library `docker-py` is a requirement for any components of the role outside of installing the Docker-Engine itself. However the role will take care of installing it, if so configured.



Role Variables
--------------

### Execution Control

Enables or disables specific components of the Docker Role.

|             Variable Name            | Default |                                                                  Description                                                                 |
|:------------------------------------:|--------:|:--------------------------------------------------------------------------------------------------------------------------------------------:|
|          `docker_manage_py`          |  `true` |                      Installs docker-py, either from repo or pip. **Note:** This is required for credential management.                      |
|      `docker_manage_engine_repo`     |  `true` |                  Manages the Docker repo. Provides support for both the Open Source and Commercially Supported Repositories.                 |
|    `docker_manage_engine_storage`    | `false` | If true, the storage driver for the Docker Engine will be managed by the role. No storage-driver or storage-opt should be supplied manually. |
|     `docker_manage_engine_users`     |  `true` |                              Creates and manages a docker group that is granted rights to interact with Docker.                              |
| `docker_manage_registry_credentials` |  `true` |                           Manages the credentials for a supplied list of registries. **Note:** Requires docker-py.                           |
|    `docker_manage_engine_networks`   |  `true` |                                Enables Management of Docker Container Networks. **Note:** Requires docker-py.                                |
|        `docker_manage_images`        |  `true` |                                     Manages lifecycle of Container Images. **Note:** Requires docker-py.                                     |
|      `docker_manage_containers`      |  `true` |                                Enables Management of Docker Container Execution. **Note:** Requires docker-py.                               |

----------



### Docker-py

Manages the installation of the docker-py libraries.

|          Variable          | Default |      Options      |                                   Description                                  |
|:--------------------------:|:-------:|:-----------------:|:------------------------------------------------------------------------------:|
|     `docker_py_install`    |  `pip`  |   `pip` or `pkg`  |                Type of installation. Either from pip or package.               |
| `docker_py_pip_extra_args` |    -    |         -         | Extra arguments to pass to pip during execution. e.g. `-i <local pypi mirror>` |
|   `docker_py_pip_upgrade`  |  `true` | `true` or `false` |            Allow for pip to be upgraded during the install process.            |
|     `docker_py_version`    |    -    |         -         |      The version of the docker-py library to install. Defaults to latest.      |

----------



### Docker Engine Repository

Controls the repository configuration of the Docker Engine.

|            Variable Name            |                    Default                   |      Options      |                             Description                             |
|:-----------------------------------:|:--------------------------------------------:|:-----------------:|:-------------------------------------------------------------------:|
|  `docker_engine_commercial_support` |                    `false`                   | `true` or `false` |      Use the Open Source or Commercially managed Docker Engine.     |
| `docker_engine_repo_gpg_key_server` |             `sks-keyservers.net`             |         -         | The keyserver to use for the validation of the repository gpg keys. |
|   `docker_engine_repo_cs_gpg_key`   | `0xEE6D536CF7DC86E2D7D56F59A178AC6C6238F52E` |         -         |           The gpg key used for the Commercial Docker Repo.          |
|   `docker_engine_repo_os_gpg_key`   | `0x58118E89F3A912897C070ADBF76221572C52609D` |         -         |          The gpg key used for the Open Source Docker Repo.          |

----------



### Docker Engine Storage Configuration

Manages the Docker Engine storage driver, and in certain circumstances the storage underneath it. Comparing the different storage options is out of scope for this document; however further information can be found here: https://docs.docker.com/engine/userguide/storagedriver/selectadriver/.

**Note:** For all storage drivers, the `storage_opts` must be passed in the form of an array of items. For more information regarding the available and specific storage options for each driver, please see the docs here: https://docs.docker.com/v1.10/engine/reference/commandline/daemon/

**Storage Support Matrix:**

|                           | aufs | btrfs | devicemapper (lvm-direct) | overlay |
|:-------------------------:|:----:|:-----:|:-------------------------:|:-------:|
|       **CentOS 7.2**      |   -  |   x   |             x             |    x    |
|   **Debian 8 (Jessie)**   |   x  |   x   |             -             |    -    |
| **Ubuntu 14.04 (Trusty)** |   x  |   x   |             -             |    -    |
| **Ubuntu 16.04 (Xenial)** |   x  |   x   |             -             |    x    |


|          Variable Name         | Default |                     Options                    |                                         Description                                         |
|:------------------------------:|:-------:|:----------------------------------------------:|:-------------------------------------------------------------------------------------------:|
| `docker_engine_storage_driver` |    -    | `aufs`, `btrfs`, `devicemapper`, and `overlay` |                       The Storage driver to use with the Docker Engine                      |
| `docker_engine_storage_config` |    -    |                        -                       | A hash containing the information for the driver supplied by `docker_engine_storage_driver` |


#### aufs
|          Variable Name         |      Default      |                    Description                     |
|:------------------------------:|:-----------------:|:--------------------------------------------------:|
| `docker_engine_storage_driver` |       `aufs`      |                          -                         |
|             `graph`            | `/var/lib/docker` |      The root directory of the docker runtime      |
|         `storage_opts`         |         -         | Optional Storage Opts to pass to the Docker Daemon |


#### btrfs

|          Variable Name         |      Default      |                                            Description                                            |
|:------------------------------:|:-----------------:|:-------------------------------------------------------------------------------------------------:|
| `docker_engine_storage_driver` |      `btrfs`      |                                                 -                                                 |
|            `device`            |         -         | **REQUIRED** The device or partition (e.g. `/dev/sdb`) intended to be used and managed by Docker. |
|             `graph`            | `/var/lib/docker` |                              The root directory of the docker runtime                             |
|           `mkfs_opts`          |         -         |               Additional parameters to pass to `mkfs.btrfs` during volume creation.               |
|          `mount_opts`          |     `defaults`    |                        Mount parameters to use for the btrfs Docker volume.                       |
|         `storage_opts`         |         -         |                         Optional Storage Opts to pass to the Docker Daemon                        |


#### devicemapper (lvm-direct)
|          Variable Name          |               Default               |                                                                      Description                                                                     |
|:-------------------------------:|:-----------------------------------:|:----------------------------------------------------------------------------------------------------------------------------------------------------:|
|  `docker_engine_storage_driver` |            `devicemapper`           |                                                                           -                                                                          |
|             `device`            |                  -                  |                           **REQUIRED** The device or partition (e.g. `/dev/sdb`) intended to be used and managed by Docker.                          |
|            `vg_name`            |             `docker-vg`             |                                                         The name of the Docker Volume Group.                                                         |
|            `vg_opts`            |                  -                  |                                               Optional paramenters to use during Volume Group creation.                                              |
|            `lv_name`            |              `thinpool`             |                                                           The Logical Volume thinpool name.                                                          |
|          `lv_data_opts`         |         `--wipesignatures y`        |                                            Parameters to pass during creation of the data logical volume.                                            |
|        `lv_metadata_opts`       |         `--wipesignatures y`        |                                          Parameters to pass during creation of the metadata logical volume.                                          |
| `thinpool_autoextend_threshold` |                 `80`                |                             The percentage full value that defines when the thin pool Logical Volume should be extended.                             |
|  `thinpool_autoextend_percent`  |                 `20`                | The percent value (in relation to it's current size) of how much additional space should be added to thin pool Logical Volume from the Volume Group. |
|           `data_share`          |                 `95`                |                             The percent value of the space of the Volume Group to be assigned to the data Logical Volume.                            |
|         `metadata_share`        |                 `1`                 |                           The percent value of the space of the Volume Group to be assigned to the metadata Logical Volume.                          |
|          `storage_opts`         | `[ 'dm.use_deferred_removal=true']` |                                                  Optional Storage Opts to pass to the Docker Daemon                                                  |


#### overlay
|          Variable Name         |      Default      |                    Description                     |
|:------------------------------:|:-----------------:|:--------------------------------------------------:|
| `docker_engine_storage_driver` |     `overlay`     |                     -                              |
|             `graph`            | `/var/lib/docker` | The root directory of the docker runtime           |
|         `storage_opts`         |         -         | Optional Storage Opts to pass to the Docker Daemon |

----------



### Docker Engine

These parameters control the Docker Engine, and the Docker Engine Daemon.

**Note:** If `docker_manage_engine_storage` is enabled, `storage-opt` should not be supplied in the `docker_engine_opts` hash, and should instead be controlled through `docker_engine_storage_config.storage_opts`.

|       Variable Name      | Default |                                                      Description                                                     |
|:------------------------:|:-------:|:--------------------------------------------------------------------------------------------------------------------:|
|  `docker_engine_version` |    -    |              The version of the Docker Engine to install. If not supplied, the latest will be installed.             |
| `docker_engine_env_vars` |    -    |                   A hash of key-value pairs to pass to the Docker Engine as environment variables.                   |
|   `docker_engine_opts`   |    -    | A hash of key-[array of value] pairs that will be used as Docker Engine options. e.g. `dns: [ '8.8.8.8', '8.8.4.4']` |

----------



### Docker Engine Users and Groups

Manages access to the docker group on a host.

|     Variable Name     | Default |                                                       Description                                                      |
|:---------------------:|:-------:|:----------------------------------------------------------------------------------------------------------------------:|
| `docker_engine_users` |    -    | An array of usernames to be added to the docker group. These users will be able to execute docker without sudo rights. |

----------



### Docker Engine Registry Credentials

Manages authentication to Docker registries. Configuration is supplied via an array of hashes, with each hash containing key/value pairs of the options available to the Docker Login Module. For a full list of options and defaults, please see the Ansible docs on the [docker_login module](http://docs.ansible.com/ansible/docker_login_module.html).


|         Variable Name         |                        Description                        |
|:-----------------------------:|:---------------------------------------------------------:|
| `docker_registry_credentials` | Array of hashes containing Docker registry configuration. |

----------



### Container Networks

Manages the creation and deletion of Docker Networks. Networks are managed via an array of hashes, each of which contains a network config as supplied by the options available to the Docker Network module. For a full list of options and defaults, please the Ansible docs on the [docker_network module](http://docs.ansible.com/ansible/docker_network_module.html).


|   Variable Name   |                       Description                        |
|:-----------------:|:--------------------------------------------------------:|
| `docker_networks` | Array of hashes containing Docker Network configuration. |

----------



### Container Images

Manages all aspects of a container image lifecycle. Images are managed by an array of hashes containing the container image configuration. For a reference of available options, see Ansible docs regarding the [docker_image module](http://docs.ansible.com/ansible/docker_image_module.html).

|  Variable Name  |                       Description                       |
|:---------------:|:-------------------------------------------------------:|
| `docker_images` | Array of hashes containing Docker Images configuration. |

----------



### Container Execution

Manages Container runtime execution. Containers are managed by an array of hashes containing the container configuration. For a reference of available options, see Ansible docs regarding the [docker_container module](http://docs.ansible.com/ansible/docker_container_module.html).


|        Variable Name       |                         Description                        |
|:--------------------------:|:----------------------------------------------------------:|
| `docker_containers` | Array of hashes containing Docker Container configuration. |

----------



Example Playbook
----------------

A variety of examples may be found in the tests directory.

```yml
---
- name: docker
  hosts: all
  connection: local
  gather_facts: True
  tags:
   - 'docker'
  vars:
    docker_manage_py: true
    docker_manage_engine_repo: true
    docker_manage_engine_storage: true
    docker_manage_engine_users: true
    docker_engine_credentials_managed: true
    docker_manage_images: true
    docker_manage_containers: true
    docker_engine_version: '1.12.1'
    docker_engine_storage_driver: devicemapper
    docker_engine_storage_config:
      device: /dev/sdb
    docker_engine_env_vars:
      DOCKER_HOST: /var/run/docker.sock
      TLS_VERIFY: TRUE
    docker_engine_opts:
      dns:
        - '8.8.8.8'
        - '8.8.4.4'
    docker_engine_users:
      - vagrant
    docker_registry_credentials:
      - username: test
        password: testpass
        registry: registry.example.com
    docker_images:
      - name: nginx
        tag: '1.10.1-alpine'
    docker_containers:
      - name: nginx
        image: 'nginx:1.10.1-alpine'
    docker_networks:
      - name: testnet
        driver_options:
          com.docker.network.bridge.name: testnet1
        ipam_options:
          subnet: '10.255.13.1/24'
          gateway: '10.255.13.1'
```


Testing and Contributing
------------------------
Please see the [CONTRIBUTING.md](CONTRIBUTING.md) document in the repo.



License
-------

MIT



Author Information
----------

Created by Bob Killen, maintained by the Department of [Advanced Research Computing and Technical Services](http://arc-ts.umich.edu/) of the University of Michigan.
