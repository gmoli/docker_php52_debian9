## Docker image with PHP 5.2.17 and apache 2.2 for legacy projects


### Usage Example

```
docker build --tag php52_debian9 .
```


```
docker run -p 3000:80 -v /your_app:/usr/local/apache2/htdocs -d --name="php52_debian9" php52_debian9
```


### Local apache configuration example

you have to configure the proxy mode and map  to port 3000 (or the port you prefer)

```
<VirtualHost *:80>

	ServerName      url_example

        ProxyPreserveHost Off
        ProxyPass        /  http://127.0.0.1:3000/
        ProxypassReverse /  http://127.0.0.1:3000/

</VirtualHost>
```


 

