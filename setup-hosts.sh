#!/bin/bash

echo "You need to add the following entry to your hosts file (/etc/hosts):"
echo "127.0.0.1 sourcegraph.test"
echo ""
echo "This can be done with the following command:"
echo "echo '127.0.0.1 sourcegraph.test' | sudo tee -a /etc/hosts"
echo ""
echo "Would you like to run this command now? (y/n)"
read response

if [ "$response" = "y" ] || [ "$response" = "Y" ]; then
  echo "Running command..."
  echo '127.0.0.1 sourcegraph.test' | sudo tee -a /etc/hosts
  echo "Hosts file updated successfully!"
else
  echo "Skipping hosts file update. You may need to add this entry manually later."
fi