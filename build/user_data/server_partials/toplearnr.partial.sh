yum install httpd -y
service httpd start
chkconfig httpd on


echo "<html>    
<head>    
    <title>Production Server</title>
</head>    
<body>
    <div>
    <h2>Production Server</h2>
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
service httpd restart