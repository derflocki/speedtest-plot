#!/bin/sh

test -f /data/speedtest.gnu || cp /speedtest.gnu /data/
touch /data/speedtest.csv

speedtest-cli --csv | grep "," >> /data/speedtest.csv

gnuplot /data/speedtest.gnu > /data/speedtest.svg
