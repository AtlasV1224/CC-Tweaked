# ModemChannels
These programs are used to manage and reserve channels used by the modem API, allowing for efficient communication between multiple devices in a world while preventing overlap on a multiplayer server.

## Usage
By default channels 1 and 2 are reserved for talking to the to the server from the client and vice versa, and channels 1 - 999 are reserved for "Community use", either for admin or general purpose functions that anyone can use.

### Server
`ModemChannelsServer.lua` should be run on a computer that is chunk loaded at all times, and either renamed to `startup.lua` or added to the `startup.lua` file.

### Client
The client script has a few usage instructions, once installed run:
- `ModemChannels` for the usage instructions in game.
- `ModemChannels get` to get the raw reserved data, allowing for processesing and display however you deem fit.
- `ModemChannels add <Name> <Band>` to reserve a KiloBand (1000 channels) for a person
    - `<Name>` should be the name of the user that reserves the band, must be a single word consiting of alphanumeric characters only
    - `<Band>` should be the band that is reserved (2-64)