# Utility uses port 80, 443, 6033 (proxySql), 3111 (puppeteer PDF service)
yum install httpd -y
service httpd start
chkconfig httpd on


echo "<html>    
<head>    
    <title>Utility Server</title>
</head>    
<body>
    <div>
    <h2>Utility Server</h2>
</div>
</body>
<style>
body  
{  
    margin: 0;  
    padding: 0;  
    background-color:#6abadeba;  
    font-family: 'Arial';  
}
div{  
    width: 382px;  
    overflow: hidden;  
    margin: auto;  
    margin: 20 0 0 450px;  
    padding: 80px;  
    background: #23463f;  
    border-radius: 15px ;  
    position: absolute;
    top: 50%;
    left: 50%;
    margin-top: -150px;
    margin-left: -250px;
          
}  
h2{  
    text-align: center;  
    color: #277582;  
    padding: 20px;  
} 
</style>
</html>" "Hello World from $(hostname -f)"> /var/www/html/index.html

sudo npm init -y
sudo npm install express --save -g
sudo npm install phin -g
sudo npm install body-parser -g
sudo npm install async -g
sudo npm install -g puppeteer --unsafe-perm=true
sudo npm install perf_hooks -g
sudo npm install cors -g

cd currDir

service httpd restart