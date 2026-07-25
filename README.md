# Kairos

**A simple toolkit for deploying [Reticulum](https://reticulum.network/) in your local communities 

## What this project is:

Kairos exists to make deploying Reticulum easy, for anyone, without asking them to trust anything they can't read in five minutes.

It is a small set of scripts that automate the boring, error-prone parts of standing up a Reticulum node. Handles installing dependencies, writing a correct config, configuring optional interfaces, starting the service, so that the only hard part left is the part that actually matters: what you build on top of it.
## What's in the toolkit

| Script                      | Purpose                                                                                                                                                   |
| --------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `deploy.sh` / `launcher.py` | Interactive menu. pick a path, it runs the right script                                                                                                   |
| `install_client.sh`         | Turns a Debian/Ubuntu machine into a Reticulum client node. Local mesh always on. VPS backbone and RNode radio are optional, config driven add-ons        |
| `install_server.sh`         | Stands up a Reticulum transport/backbone node. Good for relaying traffic for others, listens for incoming connections. Asks before touching your firewall |
| `uninstall_client.sh`       | Cleanly removes what `install_client.sh` installed                                                                                                        |
| `kairos.conf`               | The single source of truth for  any node configuration                                                                                                    |
