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
echo substr((chunk_split((base64_encode(md5(strrev($_POST["name"])))),4,"1")) , 6 , 5);
$myname = ob_get_contents();
ob_clean();
#echo"<br>";

//My Email
echo substr((chunk_split((md5(strrev(base64_encode($_POST["email"])))),3,"4")) , 2 , 5);
$myemail = ob_get_contents();
ob_clean();
//My Org
if(!empty($_POST["org"])) {
    echo substr((chunk_split((strrev(md5(base64_encode($_POST["org"])))),3,"K")) , 15 , 5);
    $myorg = ob_get_contents();
    ob_clean();
} else {
    echo substr((chunk_split((base64_encode(md5(md5($_POST["email"])))),4,"A")) , 3 , 5);
    $myorg = ob_get_contents();
    ob_clean();
}

echo(strtoupper("$myemail-$myname-$myorg"));
$mykey = ob_get_contents();
ob_clean();
echo "SK-$mykey"
    
?>
</body>
</html>
