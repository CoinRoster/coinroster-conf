# COINROSTER DEV
server {
        listen 80;
        server_name coinroster.com www.coinroster.com;
        return 301 https://www.coinroster.com$request_uri;
}
server {
        listen 80;
        server_name coinroster.nlphd.com;
        return 301 https://coinroster.nlphd.com$request_uri;
}
server {
        listen 443 ssl;

        server_name www.coinroster.com coinroster.nlphd.com;

        root /usr/share/nginx/html/coinroster.com;
        index root.html;

        ssl_certificate /root/coinroster.com.chained.crt;
        ssl_certificate_key /root/coinroster.com.key;

        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers HIGH:!aNULL:!MD5;
        #ssl_prefer_server_ciphers on;

        ssi on;

        location / {
                try_files $uri $uri/ /root.html;
                autoindex off;
        }

        location ~* ^.*\.api$ {
                proxy_buffering off;
                proxy_set_header handler api;
                proxy_pass http://localhost:27038;
        }

        location ~ ^/(lobby|account)/ {
                proxy_buffering off;
                proxy_set_header handler static;
                proxy_set_header admin false;
                proxy_set_header root $document_root;
                proxy_pass http://localhost:27038;
        }

        location ~ ^/admin/ {
                proxy_buffering off;
                proxy_set_header handler static;
                proxy_set_header admin true;
                proxy_set_header root $document_root;
                proxy_pass http://localhost:27038;
        }

        location /error {
                alias /usr/share/nginx/html;
        }
}
server {
        listen 443 ssl;
        server_name coinroster.com;
        return 301 https://www.coinroster.com$request_uri;
}
