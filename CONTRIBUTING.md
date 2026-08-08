# Contributing to Kairos

## Structure

- `installers/lib/interfaces.sh`: one function per interface type (VPS, RNode, Server). Every installer sources this instead of writing config blocks itself. **This is the file to edit when adding a new interface type if you are looking to add i2p, tor, HF, etc.**
- `all installer files`: call the functions in `interfaces.sh`, don't write interface blocks inline.
- `utilities/add_interface.sh`: same functions, lets the user pick a custom name as well

## Adding a new interface (I2P, Tor, HF, etc.)

1. Add `write_yourprotocol_interface()` to `lib/interfaces.sh`, copying the shape of the other functions.
2. Call it from whichever installer(s) need it.
3. Add the fields to `kairos.conf` and `conf_guide.md`.
4. If it needs a running daemon (Tor/I2P proxy), check for it please

## Thank you for checking this project out!