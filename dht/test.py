import time
import requests
tfile='/sys/devices/platform/dht11@0/iio:device0/in_temp_input'
hfile='/sys/devices/platform/dht11@0/iio:device0/in_humidityrelative_input'

def read_temp_raw():
   f=open(tfile,'r')
   lines=float(f.read())/1000.0
   f.close()
   return lines

def read_humidity_raw():
   b=open(hfile,'r')
   hlines=float(b.read())/1000
   b.close()
   return hlines

while True:
   try:
     T=str(read_temp_raw())
     print(T)
     H=str(read_humidity_raw())
     print(H)
     time.sleep(2)
     #Put your own IP and Itemnames here,
     requests.put('http://192.168.1.103:8080/rest/items/<ITEMNAME>/state',T)
     requests.put('http://192.168.1.103:8080/rest/items/<ITEMNAME>/state',H)

   except IOError:
      print("I/O error")
