#!/bin/sh

timestamp() {
	date +"%s"
}
WAN_CIC_IP=$(gssdp-discover -i $GSSDP_INTERFACE -n ${GSSDP_TINMEOUT:-1} -m available --target="urn:schemas-upnp-org:service:WANCommonInterfaceConfig:1" | sed -ne "s/  Location: \(.*\)/\1/p")
echo $WAN_CIC_IP
get_total_bytes_sent() {
	curl -s "$WAN_CIC_IP" -H "Content-Type: text/xml; charset="utf-8"" -H "SoapAction:urn:schemas-upnp-org:service:WANCommonInterfaceConfig:1#GetTotalBytesSent" -d "@GetTotalBytesSent.xml" | xmlstarlet sel -t -v "//NewTotalBytesSent"
}
get_total_bytes_received() {
	curl -s "$WAN_CIC_IP" -H "Content-Type: text/xml; charset="utf-8"" -H "SoapAction:urn:schemas-upnp-org:service:WANCommonInterfaceConfig:1#GetTotalBytesReceived" -d "@GetTotalBytesReceived.xml" | xmlstarlet sel -t -v "//NewTotalBytesReceived"
}

touch /data/speedtest.csv

start=$(timestamp)
start_sent=$(get_total_bytes_sent)
start_received=$(get_total_bytes_received)

speedtest-cli --csv | grep "," >> /data/speedtest.csv

end=$(timestamp)
end_sent=$(get_total_bytes_sent)
end_received=$(get_total_bytes_received)

echo "duration: "$(($end - $start ))
echo "sent: "$(( ($end_sent - $start_sent) ))
echo "received: "$(( ($end_received - $start_received )))

echo "print (($end_sent - $start_sent)/($end - $start)*8)\n" | perl
echo ""
echo "print (($end_received - $start_received)/($end - $start)*8)\n" | perl

echo -1,\
router,\
Vienna,\
$(date '+%Y-%m-%dT%H:%M:%S'),\
0,0,\
$(echo "print (("$end_sent" - "$start_sent")/("$end" - "$start")*8)\n" | perl),\
$(echo "print (("$end_received" - "$start_received")/("$end" - "$start")*8)\n" | perl) >> /data/speedtest.csv
tail -n 1000 /data/speedtest.csv > /data/speedtest.csv.tmp
mv /data/speedtest.csv.tmp /data/speedtest.csv

gnuplot /speedtest.gnu > /data/speedtest.svg
