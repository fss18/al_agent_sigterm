Alert Logic AL Agent in Container
================
WARNING: this is non official container for Alert Logic AL Agent, use with caution.
There is no official support from Alert Logic for this Dockerfile.
Please contact author for further question

Requirements
------------
1. Docker daemon
2. Account with Alert Logic
3. Unique registration key
4. API user key (optional)
5. Customer ID (optional)

Supported Platform
================

* Kubernetes
* AWS ECS
* Docker (standalone)

Note, for AL Agent implementation in standalone Docker or ECS, I recommend to install AL Agent directly on the host and set docker bridge into promiscuous mode
more info: [click here](https://support.alertlogic.com/hc/en-us/articles/229487488-Supporting-Docker-with-the-Alert-Logic-Agent-Best-Practices)

Sample Usage in Kubernetes
================

* Look for the sample YAML file for how to use it as standalone Pod deployment
* This container is intended to run along with another containers in the same Pods
* If API user key and Customer ID is provided, it will attempt to clean up the AL Agent registration from Alert Logic backend when the Pod is terminated / destroyed

Sample Usage in Standalone Docker
================

* I don't recommend running this on standalone Docker daemon, unless if you set "--network=host" to allow the AL Agent to inspect the host network traffic
* Sample command: `docker run -d -t wellysiauw/al_agent_sigterm:latest start THREAT_MANAGER_IP UNIQUE REG KEY API KEY CID DEN`
* If the docker host can access internet directly, change THREAT_MANAGER_IP to "" (empty parameter)
* If API user key and Customer ID is provided, it will attempt to clean up the AL Agent registration from Alert Logic backend when the container is stopped. Dont try to re-start the container, instead delete and recreate it.


Arguments
================

``ACTION``
----------

* Select either 'start' , 'configure' or 'provision'.
* For normal operation, use 'start'

``HOST``
----------

* To set the single point of egress, if the container can access internet directly, set it to "" (empty parameter)

``ALERTLOGIC_KEY``
-------------------

* This is the unique registration key that is required to register AL Agent.

``API_KEY``
------------

* User API key to access Alert Logic Threat Manager API end point.
* This is optional, must be provided along with 'CID' and 'DC' arguments.
* Providing this argument will trigger attempt to clean up AL Agent if the container receive terminate signal

``CID``
----------

* Customer ID from Alert Logic, each customer has unique CID
* This is optional, must be provided along with 'CID' and 'DC' arguments.
* Providing this argument will trigger attempt to clean up AL Agent if the container receive terminate signal

``DC``
----------

* Select between 'DEN' , 'ASH' and 'NPT', this indicate the Alert Logic API end point that you wish to use.
* This is optional, must be provided along with 'CID' and 'DC' arguments.
* Providing this argument will trigger attempt to clean up AL Agent if the container receive terminate signal


Contributing
============

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
===================
License:
Distributed under the Apache 2.0 license.

Authors:
Welly Siauw (welly.siauw@alertlogic.com)
