Friendly script to connect to databases through boundary with an SSO connection.

The unpaid version of the hashicorp boundary is a powerful tool with poor usability.

This script tries to improve the following aspects of the usability:
- Boundary assigns a random port for each connection
- When you have many targets, it is difficult finding the right one because the UI is unsorted
- There is no functionality that would copy the username and password automatically to the clipboard so that they can 
be pasted into your database client

Features:
- Creates a connection to the database with fix ports per database from boundary-config.sh
  - Each environment has the same port for the same database
  - It is possible to connect to different databases in the same environment with different fix ports at the same time
  - It is not possible to connect to the same database in different environments at the same time
- Copies username and password to the clipboard when the connection has been done
- Has an autocomplete function for the roles configured in boundary-autocomplete.sh


## Setup
Preconditions:
- MacOS 10.12 Sierra and later
- Bash version > 5.2
- Boundary server installed with SSO
- Boundary cli 0.12.1

Steps:
- Clone repo
- Configure in boundary-config.sh
  - Boundary addresses and authentication method ids
  - Database port mappings
- Configure the desired roles and stages for autocompletion in boundary-autocomplete.sh
- Run sudo ./install-mac.sh
- Add the following code at the end of your .bash_profile to activate autocomplete
```
###### boundary connect #####
source boundary-autocomplete.sh
complete -F _boundary_targets boundary-connect.sh
```


## Usage
- Run: `connect-db.sh DB_NAME-ROLE ENV`
  - e.g.: `connect-db.sh my-db-read-only testing`
  - The username and password will be copied to the clipboard as: 
    - `$USERNAME#PASS:$PASSWORD`
- Connect to the database with 
  - `127.0.0.1:$PORT_FROM_MAPPING`
  - Rhe username and password from the clipboard
- CTRL+C to close the connection

For further connections open a different CMD and run the same command

## Technical Details
The main technical challenge for developers with basic bash skills is that the connection command blocks the script 
and at the same time returns the credentials making it challenging to copy the created username and password.
If the command is started in the background it is challenging to get and process its output.
Besides that having the command in the background would force us to search for the process id to end the tunnel.

To solve this the following process is followed:
- Allow and create a pipe in the script
- Run connection command in the background forwarding the output to it. This will create a `job`
- Save the job_number
- Read from the pipe until the credentials are returned
- Copy credentials to clipboard
- Bring the job foreground to keep the script running and be able to close it in
























