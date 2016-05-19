pm_server
=========

Files
-----

```
.
├── build
│  ├── docker-entrypoint.sh
│  ├── Dockerfile
│  └── server.py
├── data
│  └── conf
│      └── canUpgrade
└── docker-compose.yml
```


Build the pm_server
-------------------

```
cd build/
docker build -t pm_server .
```


Start / Stop  the pm_server
---------------------------

```
# Start
docker-compose up -d

# Stop
docker-compose stop
```

Enable or Disable Upgrades
--------------------------


```
# Enable :
echo 1 > /etc/pm_server/canUpgrade

# Disable
echo 0 > /etc/pm_server/canUpgrade
```
