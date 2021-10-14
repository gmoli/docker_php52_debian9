## Docker image with PHP 5.2.17 and apache 2.2 for legacy projects


### Usage Example

```
docker build --tag php52_debian9 .
```


```
docker run -p 3000:80 -v /your_app:/usr/local/apache2/htdocs -d --name="php52_debian9" php52_debian9
```

Then navigate http://localhost:3000

