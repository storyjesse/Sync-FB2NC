# Sync-Facebook-to-NextCloud.sh

## WARNING: SCRIPT CAUSED EXCESSIVE RESOURCES USAGE - Needs fixing ##

This script downloads the .ics file that facebook makes available for a specific user. The .ics file contains all events that the user has clicked "Going" or "Interested" in.
The script then breaks this .ics file into individual events and syncs those events with Next Cloud using calendar-cli.py https://github.com/tobixen/calendar-cli
Credentials are stored in the Sync-Facebook-to-NextCloud.conf file which must be moved to ~/.local/share/WW-scripts/Sync-Facebook-to-NextCloud.conf

To Use this script change to the Temp-Calendar-Files/ directory and run
$ ../Sync-Facebook-to-NextCloud.sh
The script will download temporary .ics files to the current directory and will not find the required components if it is not in the Temp-Calendar-Files directory

### Requirements

- calendar-cli.py https://github.com/tobixen/calendar-cli
- A facebook app password needs to have been created and the credentials entered in ~/.local/share/WW-scripts/Sync-Facebook-to-NextCloud.conf
- A nextcloud app password needs to have been created and the credentials entered in ~/.local/share/WW-scripts/Sync-Facebook-to-NextCloud.conf
