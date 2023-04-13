This script provides a more user-friendly way to connect to databases through Boundary with an SSO connection. 

The unpaid version of HashiCorp Boundary can be powerful but has poor usability. 

This script improves on the following aspects of usability:
- Boundary assigns a random port for each connection, making it difficult to keep track of connections.
- The UI for managing many targets is unsorted, making it challenging to find the right one quickly.
- There is no functionality to copy the username and password automatically to the clipboard, making it cumbersome to use them in your database client. 


This script improves on these issues and offers additional features, including:
- Creating a connection to the database with fixed ports per database from boundary-config.sh.
- Each environment has the same port for the same database, making it easier to manage connections.
  - It's possible to connect to different databases in the same environment with different fixed ports at the same time.
  - It's not possible to connect to the same database in different environments at the same time.
- Copying the username and password to the clipboard automatically when the connection is established.
- Autocomplete functionality for the roles configured in boundary-autocomplete.sh.


## Setup
### Prerequisites
- MacOS 10.12 Sierra and later
- Bash version > 5.2
- Boundary server installed with SSO configured
- Boundary cli 0.12.1

### Installation
Follow these steps to install and configure the script:

1. Clone the repo.
2. Configure the boundary-config.sh file with the appropriate boundary addresses and authentication method IDs.
3. Configure the desired roles and stages for autocompletion in boundary-autocomplete.sh.
4. Run sudo ./install-mac.sh to install the script.
5. Add the following code at the end of your .bash_profile file to activate autocomplete:
```
###### boundary connect #####
source boundary-autocomplete.sh
complete -F _boundary_targets boundary-connect.sh
```


## Usage
To use the script, run the following command:
`connect-db.sh DB_NAME-ROLE ENV`

For example:
`connect-db.sh my-db-read-only testing`

The script will copy the username and password to the clipboard 
in the format `$USERNAME#PASS:$PASSWORD`. 

Connect to the database with:
- 127.0.0.1:$PORT_FROM_MAPPING
- The username and password from the clipboard

Press CTRL+C to close the connection.

For further connections, open a different terminal window and run the same command.

## Technical Details
The main technical challenge for developers with basic Bash skills is that 
the connection command blocks the script and returns the credentials simultaneously, 
making it challenging to copy the created username and password. 
If the command is started in the background, it is difficult to get and process its output. 
Additionally, having the command in the background would force us to search for the process ID to end the tunnel.

To solve this problem, the script follows this process:
1. Allow and create a pipe in the script.
2. Run the connection command in the background, forwarding the output to the pipe. This will create a job.
3. Save the job number.
4. Read from the pipe until the credentials are returned.
5. Copy the credentials to the clipboard.
6. Bring the job to the foreground to keep the script running and be able to close it when needed.
























