rm -rf ~/.local/share/letsencrypt
rm -rf /opt/eff.org/certbot/
unset PYTHON_INSTALL_LAYOUT
#sau do chay sudo /home/vinhlq/certbot-auto --apache --debug
#/root/.local/share/letsencrypt/bin/pip install --upgrade certbot


#git clone https://github.com/letsencrypt/letsencrypt
/opt/letsencrypt/letsencrypt-auto renew --debug
service httpd restart
