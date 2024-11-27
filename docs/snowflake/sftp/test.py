import paramiko

# Connection details
hostname = 'danielwilczakv2.blob.core.windows.net'
port = 22  # Default SFTP port
username = 'danielwilczakv2.data.danielwilczak'
password = 'wnpJkX4p1LoZVWCF34DKtmDgVfsXmqO6'

# Initialize the SFTP connection
try:
    # Create an SSH client
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())  # Automatically add unknown host keys

    # Connect to the host
    client.connect(hostname=hostname, port=port, username=username, password=password)

    # Open SFTP session
    sftp = client.open_sftp()
    print("Connected to SFTP server successfully.")

    # Example operation: list files in the root directory
    for file in sftp.listdir():
        print(file)

    # Close the SFTP session and the SSH client
    sftp.close()
    client.close()
    print("SFTP connection closed.")

except Exception as e:
    print(f"Failed to connect to SFTP server: {e}")
