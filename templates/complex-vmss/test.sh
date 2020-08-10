url="http://$1.eastus.cloudapp.azure.com/"
echo "testing $url"
curl $url 2>/dev/null
echo