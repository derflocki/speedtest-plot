#!/bin/sh

timestamp() {
	date +"%s"
}
WAN_CIC_IP=$(gssdp-discover -i $GSSDP_INTERFACE -n ${GSSDP_TINMEOUT:-1} -m available --target="urn:schemas-upnp-org:service:WANCommonInterfaceConfig:1" | sed -ne "s/  Location: \(.*\)/\1/p")
echo "WANCommonInterfaceConfig Url:" $WAN_CIC_IP
get_total_bytes_sent() {
	curl -s "$WAN_CIC_IP" -H "Content-Type: text/xml; charset="utf-8"" -H "SoapAction:urn:schemas-upnp-org:service:WANCommonInterfaceConfig:1#GetTotalBytesSent" -d "@GetTotalBytesSent.xml" | xmlstarlet sel -t -v "//NewTotalBytesSent"
}
get_total_bytes_received() {
	curl -s "$WAN_CIC_IP" -H "Content-Type: text/xml; charset="utf-8"" -H "SoapAction:urn:schemas-upnp-org:service:WANCommonInterfaceConfig:1#GetTotalBytesReceived" -d "@GetTotalBytesReceived.xml" | xmlstarlet sel -t -v "//NewTotalBytesReceived"
}
output() {
	echo "Bytes $2: $1 ($(echo "print ($1/1024/1024)" | perl) MB)"
}
touch /data/speedtest.csv

start=$(timestamp)
start_sent=$(get_total_bytes_sent)
start_received=$(get_total_bytes_received)

echo $(output ${start_sent} "Out") $(output ${start_received} "In ")
echo "Running speedtest..."
speedtest-cli --csv | grep "," | tee -a /data/speedtest.csv
end=$(timestamp)
end_sent=$(get_total_bytes_sent)
end_received=$(get_total_bytes_received)

echo $(output ${end_sent} "Out") $(output ${end_received} "In ")
echo ""

duration=$(($end - $start))
echo "duration: $duration"

output $(( ($end_sent - $start_sent) )) Out
output $(( ($end_received - $start_received ))) "In "


bits_up=$(echo   "print ((8*($end_sent     - $start_sent    ))/$duration)" | perl)
bits_down=$(echo "print ((8*($end_received - $start_received))/$duration)" | perl)

echo "Up: $(echo "print (($bits_up/1024/1024))" | perl) Down:  $(echo "print (($bits_down/1024/1024))" | perl)"

echo -1,\
router,\
Vienna,\
$(date '+%Y-%m-%dT%H:%M:%S'),\
0,0,\
$(echo $bits_down),\
$(echo $bits_up) | tee -a /data/speedtest.csv
tail -n 1000 /data/speedtest.csv > /data/speedtest.csv.tmp
mv /data/speedtest.csv.tmp /data/speedtest.csv

gnuplot /speedtest.gnu > /data/speedtest.svg
