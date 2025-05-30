# launch-template-user-data.sh
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Welcome to My Scalable Web App</h1>" > /var/www/html/index.html