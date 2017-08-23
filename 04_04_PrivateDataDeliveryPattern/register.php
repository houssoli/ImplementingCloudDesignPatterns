<?php  //Start the Session
   function el_crypto_hmacSHA1($key, $data, $blocksize = 64) {
       if (strlen($key) > $blocksize) $key = pack('H*', sha1($key));
       $key = str_pad($key, $blocksize, chr(0x00));
       $ipad = str_repeat(chr(0x36), $blocksize);
       $opad = str_repeat(chr(0x5c), $blocksize);
       $hmac = pack( 'H*', sha1(
       ($key ^ $opad) . pack( 'H*', sha1(
         ($key ^ $ipad) . $data
       ))
     ));
     return base64_encode($hmac);
   }

   function el_s3_getTemporaryLink($accessKey, $secretKey,
                                   $bucket, $path, $expires = 5) {
     $expires = time() + intval(floatval($expires) * 60);
     $path = str_replace('%2F', '/',
                         rawurlencode($path = ltrim($path, '/')));
     $signpath = '/'. $bucket .'/'. $path;
     $signsz = implode("\n", $pieces = array('GET', null, null,
                                             $expires, $signpath));
     $signature = el_crypto_hmacSHA1($secretKey, $signsz);
     $url = sprintf('http://%s.s3.amazonaws.com/%s', $bucket, $path);
     $qs = http_build_query($pieces = array(
       'AWSAccessKeyId' => $accessKey,
       'Expires' => $expires,
       'Signature' => $signature,
     ));
     return $url.'?'.$qs;
   }

   if ($_POST['username'] == "admin" && $_POST['password'] == "legit") {
     echo el_s3_getTemporaryLink('MY_ACCESS_KEY', 'MY_SECRET_KEY',
                                 'a6408e3f-bc3b-4dab-9749-3cb5aa449bf6',
                                 'importantstuff.zip');
   } else {
     header('Location: index.php');
   }
?>
