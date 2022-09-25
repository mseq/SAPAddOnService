import subprocess
import logging
import socket
# import sys

def run(cmd):
    logger.info (f'CmdRun - {cmd}')
    completed = subprocess.run(["powershell", "-Command", cmd], capture_output=True)
    try:
        logger.info(f"STDOUT: {completed.stdout.decode('utf-8')}")
        logger.info(f"STDERR: {completed.stderr.decode('utf-8')}")
    except Exception as e:
        logger.error(e)
        
    return completed        

# create logger
logging.basicConfig(filename='InstallAndConfigureRDS.log', format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger('RDS')
ch = logging.StreamHandler()
logger.setLevel(logging.DEBUG)
ch.setLevel(logging.DEBUG)
formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
ch.setFormatter(formatter)
logger.addHandler(ch)


# Create a TCP/IP socket
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Bind the socket to the port
server_address = ('0.0.0.0', 4489)
logger.info (f'starting up on {server_address[0]} port {server_address[1]}')
sock.bind(server_address)

# Listen for incoming connections
sock.listen(1)

bolFirstDeploy=True
ConnectionBroker="WIN-D93JRF7S9BL.SAP.VALTELLINA.CORP"

while True:
    # Wait for a connection
    logger.info ('waiting for a connection')
    connection, client_address = sock.accept()

    try:
        logger.info (f'connection from {client_address}')

        # Receive the data in small chunks and retransmit it
        while True:
            data = connection.recv(128).decode("utf-8").strip()
           
            logger.info (f'received "{data}"')
            if data:
                hostname = str(client_address[0]).replace(".", "-") + ".sap.valtellina.corp"
                if data.find("RDS-CONFIG") >= 0:
                    logger.info (f'Protocol ok - {data}')
                    logger.info (f'Starting RDS Configuration on server: {hostname}')

                    res = run(f"c:\cfn\AddServerToManager.ps1 {hostname}")
                    res = run("Import-Module RemoteDesktop; $res = Get-RDServer | Measure-Object -line; echo $res.Lines")

                    if int(res.stdout.decode("utf-8")) >= 2:
                        res = run(f"Import-Module RemoteDesktop; Add-RDServer -Server {hostname} -Role RDS-RD-SERVER -ConnectionBroker {ConnectionBroker}")
                    else:
                        res = run(f"Import-Module RemoteDesktop; New-RDSessionDeployment -ConnectionBroker {ConnectionBroker} -WebAccessServer {hostname} -SessionHost {hostname}")

                elif data.find("FINISHED") >= 0:
                    logger.info (f'Protocol ok - {data}')

                    res = run(f"Import-Module RemoteDesktop; Get-RDServer | findstr /I {hostname}")

                    if res.stdout.decode("utf-8").find("RDS-WEB-ACCESS") < 0:
                        res = run(f"Import-Module RemoteDesktop; Add-RDServer -Server {hostname} -Role RDS-WEB-ACCESS -ConnectionBroker {ConnectionBroker}")
                        
                    logger.info (f'Bootstrap finished on host: {hostname}')

                else:
                    logger.info (f'Not a command - {data}')
            else :
                logger.info ('End of data')
                break
    except Exception as e:
        logger.error (e)
    finally:
        # Clean up the connection
        connection.close()

