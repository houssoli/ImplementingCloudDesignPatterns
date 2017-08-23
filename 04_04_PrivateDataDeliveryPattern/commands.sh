#!/bin/sh
sudo yum groupinstall -y "Web Server" "PHP Support" >/dev/null 2>&1
sudo chown -R ec2-user /var/www && sudo chmod 2775 /var/www
sudo su ec2-user -
find /var/www -type d -exec sudo chmod 2775 {} + &&  find /var/www -type f -exec sudo chmod 0664 {} +
sudo service httpd start >/dev/null 2>&1
cat <<EOF >/var/www/html/index.php
<?xml version="1.0" encoding="UTF-8"?>
<html>
  <head>
    <title>login</title>
  </head>
  <body>
    <div class="register-form">
      <h1>Login</h1>
      <form action="register.php" method="POST">
        <p>
          <label>User Name : </label>
          <input id="username" type="text" 
            name="username" placeholder="username" />
        </p>
        <p>
          <label>Password&nbsp;&nbsp; : </label>
          <input id="password" type="password" 
            name="password" placeholder="password" />
        </p>
        <a class="btn" href="register.php">Signup</a>
        <input class="btn register" type="submit" 
          name="submit" value="Login" />
      </form>
    </div>
  </body>
</html>
EOF
cat <<EOF >/var/www/html/register.php
 <?php  //Start the Session
   function el_crypto_hmacSHA1(\$key, \$data, \$blocksize = 64) {
       if (strlen(\$key) > \$blocksize) \$key = pack('H*', sha1(\$key));
       \$key = str_pad(\$key, \$blocksize, chr(0x00));
       \$ipad = str_repeat(chr(0x36), \$blocksize);
       \$opad = str_repeat(chr(0x5c), \$blocksize);
       \$hmac = pack( 'H*', sha1(
       (\$key ^ \$opad) . pack( 'H*', sha1(
         (\$key ^ \$ipad) . \$data
       ))
     ));
     return base64_encode(\$hmac);
   }

   function el_s3_getTemporaryLink(\$accessKey, \$secretKey,
                                   \$bucket, \$path, \$expires = 5) {
     \$expires = time() + intval(floatval(\$expires) * 60);
     \$path = str_replace('%2F', '/',
                         rawurlencode(\$path = ltrim(\$path, '/')));
     \$signpath = '/'. \$bucket .'/'. \$path;
     \$signsz = implode("\n", \$pieces = array('GET', null, null,
                                             \$expires, \$signpath));
     \$signature = el_crypto_hmacSHA1(\$secretKey, \$signsz);
     \$url = sprintf('http://%s.s3.amazonaws.com/%s', \$bucket, \$path);
     \$qs = http_build_query(\$pieces = array(
       'AWSAccessKeyId' => \$accessKey,
       'Expires' => \$expires,
       'Signature' => \$signature,
     ));
     return \$url.'?'.\$qs;
   }

   if (\$_POST['username'] == "admin" && \$_POST['password'] == "legit") {
     echo el_s3_getTemporaryLink('MY_ACCESS_KEY', 'MY_SECRET_KEY',
                                 'a6408e3f-bc3b-4dab-9749-3cb5aa449bf6',
                                 'importantstuff.zip');
   } else {
     header('Location: index.php');
   }
 ?>
EOF 
TEMP_URL=$(curl --silent -X POST -d "username=admin&password=legit" http://10.203.10.123/register.php)
curl -sL -w "%{http_code}\\n" $TEMP_URL
sleep 301 && curl -sL -w "%{http_code}\\n" $TEMP_URL
