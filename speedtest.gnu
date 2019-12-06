set terminal svg enhanced size 1600,900 font "Arial,16"

set grid
set pointsize 0.1

set key right bottom
set key spacing 2.0
#set nokey

set yrange [0:*]
set ylabel 'Up/Down (MBit/s)' tc lt 2
set ytics 5
set mytics 1

set y2range [0:*]
set y2label 'Up/Down (MBit/s)' tc lt 2
set y2tics 5
set my2tics 1


#2018-02-16T15:18:13.804179

set xdata time
set timefmt "%Y-%m-%dT%H:%M:%S"
set format x "%d.%m %H:%M"

set datafile separator ","

plot \
\
"/data/speedtest.csv" using 4:($7/1024/1024)  with linespoints lt 1 lc rgb "blue" lw 2 axes x1y2 title 'Down', \
                   "" using 4:($8/1024/1024)  with linespoints lt 1 lc rgb "green" lw 2 axes x1y2 title 'Up', \
				   "< tail -n 1 /data/speedtest.csv" using 4:($7/1024/1024):(sprintf("%5.2f",$7/1024/1024)) with labels center offset 0,-1 tc rgb "blue" notitle, \
				   "" using 4:($8/1024/1024):(sprintf("%5.2f",$8/1024/1024)) with labels center offset 0,-1 tc rgb "green" notitle



