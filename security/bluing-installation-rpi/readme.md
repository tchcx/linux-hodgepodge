
## Updates
```
sudo apt update && sudo apt upgrade
```

## Dependencies
It threw errors on build (RaspPi4/ARM64) until ibgirepository-2.0-dev was added (appended below)
```
sudo apt install -y python3-pip python3-dev libcairo2-dev libgirepository1.0-dev \
                 libbluetooth-dev libdbus-1-dev bluez-tools python3-cairo-dev \
                 rfkill meson patchelf bluez ubertooth adb python-is-python3 \
                 libgirepository-2.0-dev -y
```

# Create and enter venv dir
```
mkdir bluing && cd bluing
```

# Install correct version of Python (3.10)
We use this version to create the venv
```
sudo apt install -y python3.10 python3.10-venv
```

## Make virtual environment
And activate it if successful
```
python3.10 -m venv .venv && source .venv/bin/activate
```

# Check path to python3.10 and pip3.10
```
We'd want them in .venv/bin in
this case (despite also being installed globally)
which python3.10 pip3.10
```

# Installed to reduce warnings during the build
(Never mind, it just changes them a little. But I stand by this)
```
.venv/bin/pip3.10 install --upgrade pip setuptools wheel
.venv/bin/pip3.10 install bluing
```

# And it should be in the venv and your path:
```
which bluing
```
