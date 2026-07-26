# Kairos

**A simple toolkit for deploying [Reticulum](https://reticulum.network/) in your local communities**

## What this project is:

Kairos exists to make deploying Reticulum easy for anyone.

It is a small set of scripts that automate the boring parts of standing up a Reticulum node. Handles installing dependencies, writing a correct config, configuring optional interfaces, starting the service, so that the only hard part left is the part that actually matters: what you build on top of it.
## What's in the toolkit

| Script                      | Purpose                                                                                                                                                   |
| --------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `deploy.sh` / `launcher.py` | Interactive menu. pick a path, it runs the right script                                                                                                   |
| `install_client.sh`         | Turns a Debian/Ubuntu machine into a Reticulum client node. Local mesh always on. VPS backbone and RNode radio are optional, config driven add-ons        |
| `install_server.sh`         | Stands up a Reticulum transport/backbone node. Good for relaying traffic for others, listens for incoming connections. Asks before touching your firewall |
| `uninstall_client.sh`       | Cleanly removes what the installers added                                                                                                                 |
| `add_interface.sh`          | Simply add a new interface to your reticulum config                                                                                                       |
| `kairos.conf`               | The single source of truth for  any node configuration                                                                                                    |

## How to Use

### 1. Clone the repo

```bash
git clone https://github.com/Time-Walked/Kairos
cd Kairos
```

### 2. Configure your node

Open `kairos.conf` in any text editor. Every setting is off/blank by default — nothing gets enabled without you explicitly turning it on.

```bash
nano kairos.conf
```

- **Local mesh only?** Leave everything as-is. 
- **Want to connect to a VPS backbone?** Set `VPS_ENABLED=yes` and fill in `VPS_HOST`, `VPS_PORT`, and `VPS_NETWORK_NAME`.
- **Have an RNode radio?** Set `RNODE_ENABLED=yes` and fill in `RNODE_PORT` (find it with `ls /dev/ttyUSB* /dev/ttyACM*`). The frequency/bandwidth/etc. 
- **Standing up a server/backbone node instead?** Fill in `SERVER_LISTEN_IP` and `SERVER_LISTEN_PORT` under the server section. 
- **Need to add a new interface?** Just run the "add an interface" tool from the launcher! 

### 3. Run the launcher

```bash
./deploy.sh
```

You'll get a menu:

```
1  Client install
2  Server install
3  Add an interface
4. Exit
```

- **Client install:** turns this machine into a Reticulum node using whatever you set in `kairos.conf`. Installs `rnsd` and `nomadnet`, writes a Reticulum config, starts it as a systemd service that survives reboot and logout.
- **Server install:** turns this machine into a transport/backbone node others can connect to. Will ask for explicit confirmation before opening any firewall port.

You can also skip the menu and run either script directly:

```bash
./install_client.sh
./install_server.sh
./add_interface.sh
```

### 4. Check it's running

```bash
systemctl --user status rnsd.service
```

### 5. Uninstalling

```bash
./uninstall_client.sh
```

This stops and disables the service, removes installed packages, and cleans up your PATH changes. It will separately — and explicitly — ask before touching your Reticulum identity, since that step can't be undone.

### Re-running / reconfiguring

Every install script here is safe to re-run. Change something in `kairos.conf` and run the install script again, your existing config gets backed up (timestamped, never overwritten blind) before the new one is written.

**One thing worth knowing:** if `rnsd` is already running when you change `kairos.conf` and re-run the install script, the new config is written to disk but the running service won't pick it up automatically. Restart it to apply changes:

```bash
systemctl --user restart rnsd.service
```
---

## Use Cases

### Mutual Aid Networks
Deploy mesh for coordinating disaster response, resource distribution, and community care without dependency on infrastructure that fails during crises.

### Community Organizing
Secure communications for organizing actions, coordinating logistics, maintaining operations under surveillance or in hostile environments.

### Independent Press
Infrastructure to protect sources and maintain communications when corporate platforms face censorship or compromise.

### Disaster Preparedness
Backup communications when cellular/internet fails. Pre-deployed, tested, ready when needed.

### Privacy-Focused Communities  
Communications outside surveillance capitalism while maintaining usability for non-technical members.

---

## Credits

KAIROS stands on the shoulders of:

**Mark Qvist ([@markqvist](https://github.com/markqvist))** - Creator of Reticulum, RNode, Nomadnet, LXMF. This project would not exist without Mark's foundational work on the protocol and ecosystem.

**KAIROS is automation work,** taking excellent FOSS tools and making them deployable by communities who need resilient communications.

---

**Build infrastructure that lasts. Share knowledge freely. Own your communications.**
