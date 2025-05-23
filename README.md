# ICDCN_2025
This repository will help you setup 1-cu, 1-du, and 1-ue with open5gs and ric.

# srsRAN, srsUE with RIC Setup Guide

## Prerequisites
Ensure your system is up to date before proceeding with the installation.

```bash
sudo apt-get update && sudo apt-get upgrade -y

# Install cmake and make
sudo apt-get update
sudo apt-get install -y cmake make build-essential libfftw3-dev libmbedtls-dev libboost-program-options-dev libconfig++-dev libsctp-dev
```

## Docker and dependencies Installation

The following script removes any existing Docker installations and installs the latest version along with srsRAN_4G dependencies:

```bash
#!/bin/bash
$
# Remove existing Docker packages
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
    sudo apt-get remove -y $pkg;
done

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository:
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker and other dependencies for srsUE_4G
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin build-essential cmake libfftw3-dev libmbedtls-dev libboost-program-options-dev libconfig++-dev libsctp-dev libzmq3-dev


# Verify Docker installation
sudo docker run hello-world

# Add user to Docker group
sudo groupadd docker
sudo usermod -aG docker $USER

# Enable Docker services
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
```

To apply the group changes, either reboot or run:
```bash
newgrp docker
```
Then, verify Docker runs without sudo:
```bash
docker run hello-world
```
Then, create the docker network required for the setup:
```bash
docker network create --subnet=10.0.0.0/8 oran-icdcn
```

## Cloning and Setting Up srsRAN

### Step 1: Clone the srsRAN Project Repository and checkout
```bash
cd RAN
git clone https://github.com/srsran/srsRAN_Project.git
cd srsRAN_Project
git checkout e5d5b44
cd ../..
```

### Step 2: Build UE
```bash
cd UE/
git clone https://github.com/srsran/srsRAN_4G.git
cd srsRAN_4G
mkdir build
cd build
cmake ../
make -j$(nproc)
cd ../../../
```

### Step 3: Clone and Set Up RIC
```bash
mkdir -p RIC
cd RIC/
git clone https://github.com/srsran/oran-sc-ric.git
cd ../
```

# To run the project you can either use docker-compose files or shell scripts depending on your convinience
## Using docker-compose files to run the project (Except RIC which is easier to deploy using docker-compose file)
### Terminal 1: Prepare and Start RIC from root directory
```bash
cp -f setup/srsRAN_Project/docker-compose.yml RAN/srsRAN_Project/docker/docker-compose.yml
cp -f setup/srsRAN_Project/open5gs.env RAN/srsRAN_Project/docker/open5gs/open5gs.env
cp -f setup/srsRAN_Project/subscriber_db.csv RAN/srsRAN_Project/docker/open5gs/subscriber_db.csv
cp -f setup/oran-sc-ric/docker-compose.yml RIC/oran-sc-ric/docker-compose.yml
cp -f setup/srsRAN_Project/Dockerfile RAN/srsRAN_Project/docker/Dockerfile
cp -f setup/srsRAN_Project/install_dependencies.sh RAN/srsRAN_Project/docker/scripts/install_dependencies.sh
```

Then, start RIC:
```bash
# Run from O-RAN_srsRAN (Project root directory) after inside screen with name RIC

cd RIC/oran-sc-ric
docker compose up
```

### Terminal 2: Start srsRAN from root directory
```bash
# Run from O-RAN_srsRAN (Project root directory) after inside screen with name RAN

docker compose up
```
### Terminal 3: To run the KPI-mon xapp
```bash
cd RIC/oran-sc-ric
docker exec -it python_xapp_runner ./kpm_mon_xapp.py --kpm_report_style=1
```
This setup ensures that all required components for RIC and srsRAN are properly installed and running.



## Using shell scripts to run the setup
## 🛠️ Build Docker Images

You must build the Docker images before running containers.

### ✅ Build `open5gs`

```bash
docker build \
  --build-arg OS_VERSION=22.04 \
  --build-arg OPEN5GS_VERSION=v2.7.0 \
  -t srsran/open5gs:latest \
  -f RAN/srsRAN_Project/docker/open5gs/Dockerfile \
  RAN/srsRAN_Project/docker/open5gs
```

### ✅ Build `srsran:split_8_zmq` (used by CU0 and DU0)

```bash
docker build \
  --build-arg OS_VERSION=22.04 \
  -t srsran:split_8_zmq \
  -f RAN/srsRAN_Project/docker/Dockerfile \
  RAN/srsRAN_Project/
```

### ✅ Build `srsue:split_8_zmq`

```bash
docker build \
  --build-arg OS_VERSION=22.04 \
  -t srsue:split_8_zmq \
  -f UE/Dockerfile \
  UE/
```

### ✅ Build `srsran/metrics_server`

```bash
docker build \
  -t srsran/metrics_server \
  RAN/srsRAN_Project/docker/metrics_server
```

### ✅ Build `srsran/grafana`

```bash
docker build \
  -t srsran/grafana \
  RAN/srsRAN_Project/docker/grafana
```

---

## ▶️ Run Containers Individually

Ensure all shell scripts are executable:

```bash
chmod +x run_5gc.sh run_cu0.sh run_du0.sh run_ue0.sh \
         run_metrics_server.sh run_influxdb.sh run_grafana.sh run_redis.sh
```

### Recommended Run Order

Start containers in the following order for correct dependency resolution:

1. **Redis**
   ```bash
   ./run_redis.sh
   ```

2. **InfluxDB**
   ```bash
   ./run_influxdb.sh
   ```

3. **Metrics Server**
   ```bash
   ./run_metrics_server.sh
   ```

4. **Grafana**
   ```bash
   ./run_grafana.sh
   ```

5. **5GC (Open5GS Core Network)**
   ```bash
   ./run_5gc.sh
   ```

6. **CU0 (Central Unit)**
   ```bash
   ./run_cu0.sh
   ```

7. **DU0 (Distributed Unit)**
   ```bash
   ./run_du0.sh
   ```

8. **UE0 (User Equipment)**
   ```bash
   ./run_ue0.sh
   ```

---

## 📁 Volumes and Configuration Notes

- Make sure the following config files exist:
  - `RAN/cu_0.yml`
  - `RAN/du_zmq.conf`
  - `UE/ue_zmq.conf`
  - `.env` file for environment variables

- Mounted UHD image directory should be present:
  - `/usr/share/uhd/images`

---

## 🧪 Verification

Use these commands to check container status and logs:

```bash
docker ps
docker logs <container_name>
```

---

## 🧹 Cleanup (Optional)

To stop all running containers and remove unused data:

```bash
docker stop $(docker ps -q)
docker system prune -af
```

---
