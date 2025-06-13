#!/bin/bash

echo "Menunggu 15 detik sebelum memulai mining..."
for i in {15..1}; do
  echo -ne "\rMenunggu $i detik..."
  sleep 1
done

while true; do
  suhu=$(cat /sys/class/thermal/thermal_zone0/temp)
  suhu=$((suhu / 1000))
  echo "Suhu saat ini: $suhu°C"
  
  if [ $suhu -lt 38 ]; then
    echo "Suhu aman, memulai mining..."
    cd ccminer
    ./start.sh &
    pid=$!
    trap "echo 'Mining dihentikan...'; kill $pid; exit" SIGINT
    
    while [ $suhu -lt 40 ]; do
      suhu=$(cat /sys/class/thermal/thermal_zone0/temp)
      suhu=$((suhu / 1000))
      echo "Suhu saat ini: $suhu°C"
      sleep 60
    done
    
    echo "Suhu terlalu tinggi, mining dihentikan..."
    kill $pid
    cd ..
  else
    echo "Suhu terlalu tinggi, menunggu suhu turun..."
    while [ $suhu -ge 38 ]; do
      suhu=$(cat /sys/class/thermal/thermal_zone0/temp)
      suhu=$((suhu / 1000))
      echo "Menunggu suhu turun... ($suhu°C)"
      sleep 60
    done
  fi
done
