echo "Beginning update process!"

apt update -y && apt upgrade -y || pkg update && pkg upgrade

echo "Done!"
read
