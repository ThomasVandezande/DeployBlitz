# DeployBlitz
This Script automates the deployment of the Blitz First Responder PowerBI Dashboard
https://www.brentozar.com/first-aid/first-responder-kit-power-bi-dashboard/

It will:
- Restore the 'DBATools' database with the necessary procedures
- Create a SQL job called 'MESS_FetchPerformance' that runs every hour

The 'minute' of the hour on which the SQL job runs is randomized for every instance to prevent overloading a big cluster everytime all instances their job kicks in.

# How-to
- Copy the modules folder to your 'C:\Program Files\WindowsPowerShell\Modules' folder (or c:\Users\USERNAME\Documents\WindowsPowershell\Modules)
- Provide the instance names in the 'Servers.csv' sheet
- Run the script

# Troubleshooting
As with my other scripts a basic logging module is included. Errors not fetched in there will be displayed in your Powershell window.

## TODO
- Implement Redeployment option
- Implement option to change SQL Job name
- Implement option to change SQL Database name
- Implement on/off option for the randomize of the SQL job minutes
