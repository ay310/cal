#!/usr/bin/ruby
# coding: utf-8

require 'sqlite3'
require 'cgi'
require 'kconv'
print "Content-type: text/html\n\n"

print "<!DOCTYPE html>"
print "<html>"
print "	<head>"
print "		<meta name=\"viewport\" content=\"initial-scale=1.0,user-scalable=no\">"
print "		<meta charset=\"utf-8\">"
print "		<title>Reverse Geocoding Test</title>"
print "		<script type=\"text/javascript\" src=\"http://ajax.googleapis.com/ajax/libs/jquery/1.8/jquery.min.js\"></script>"
print"		<script type=\"text/javascript\" src=\"http://maps.google.com/maps/api/js?sensor=false\"></script>"
print "   <script>"
print "var geocoder;"
print""
print"navigator.geolocation.getCurrentPosition(is_success,is_error);"
print""
print"function is_success(position) {"
print"	var gpsLat = position.coords.latitude;"
print"	var gpsLng = position.coords.longitude;"
print""
print"	gmap_init(gpsLat,gpsLng);"
print"}"
print""
print"function is_error(error) {"
print"	var result = \"\";"
print"	switch(error.code) {"
print"		case 1:"
print"			result = '位置情報の取得が許可されていません';"
print"		break;"
print"		case 2:"
print"			result = '位置情報の取得に失敗';"
print"		break;"
print"		case 3:"
print"			result = 'タイムアウト';"
print"		break;"
print"	}"
print"	document.getElementById('message').innerHTML = result;"
print"}"
print""
print"function gmap_init(gpsLat,gpsLng) {"
print"	geocoder = new google.maps.Geocoder();"
print"	var latlng = new google.maps.LatLng(gpsLat,gpsLng);"
print""
print"	geocoder.geocode({'latLng':latlng},function(results,status){"
print"		if (status == google.maps.GeocoderStatus.OK) {"
print"			console.log(results[0].formatted_address);"
print"			result 	= '現在地の取得に成功<br>';"
print"			result += '経度：' + gpsLat + '<br>';"
print"			result += '緯度：' + gpsLng + '<br>';"
print"			result += '住所：' + results[0].formatted_address + '<br>';"
print""
print"			document.getElementById('message').innerHTML = result;"
print""
print"		} else {"
print"			console.log(status);"
print"		}"
print"	});"
print"}"
print"    </script>"
print"	</head>"
print"	<body>"
print"<div id=\"message\"></div>"
print"	</body>"
print"</html>"
