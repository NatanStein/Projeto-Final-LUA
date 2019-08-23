local function wifi_connected_callback(iptable)
  print("wifi_connected_callback")
  print("ip: " .. wifi.sta.getip())
end
wificonf = {
  ssid = "Katinhaxx",
  pwd = "helena00",
  got_ip_cb = wifi_connected_callback,
  save = false,
}
wifi.setmode(wifi.STATION)
print(wifi.sta.config(wificonf))

