<html>
<body>

<?php
//md5 = md5()
//rev = strrev()
//base64 = base64_encode()
//fold & paste = chunk_split(string, period, character)
//cut = substr(string, start, length)
//length = strlen()
echo $_POST["name"];
echo "<br>";
echo $_POST["email"];
echo "<br>";
echo $_POST["org"];
?>
<br>
<br>
<?php
ob_start();
//My Name
$myname = substr((chunk_split((base64_encode(md5(strrev($_POST["name"])))),4,"1")) , 6 , 5);

//My Email
$myemail = substr((chunk_split((md5(strrev(base64_encode($_POST["email"])))),3,"4")) , 2 , 5);

//My Org
if(!empty($_POST["org"])) {
   $myorg = substr((chunk_split((strrev(md5(base64_encode($_POST["org"])))),3,"K")) , 15 , 5);
} else {
    $myorg = substr((chunk_split((base64_encode(md5(md5($_POST["email"])))),4,"A")) , 3 , 5);
}

echo strtoupper("SK-$myemail-$myname-$myorg");
    
?>
</body>
</html>
