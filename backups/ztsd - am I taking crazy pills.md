# Am I taking crazy pills?
## Is zstd actually that good?

I shoot videos at ProRes 422 proxy, 1440p60. Even proxy, they're big boys. I've been compressing (for archiving) with bzip2 and thought 50% was a solid ratio. But got curious and gave zstd a shot.

And, what?! How is this possible?




Catting -> STDIN bzip2 decompressing STDOUT -> STDIN Zstd compressing -> file

```
### Ad-hoc script
# Loop over all these
for i in *.bz2; do
  # Save start size and time into variables
  start_size=$(ls -lah $i | awk '{print $5}')
  start_time=$(date '+%H:%M:%S')
 
  # Save end file name (new extension) into variable
  end_file=${i%.bz2}.zst

  # Print start filename (snipped), size, and time; tee to log
  echo -e "START:\t${i:0:12}... ($start_size)\t\t$start_time" | tee -a log.txt

  # cat into pbzip2, gimp to 125MB and 4 proc so it doesn't back up
  # Pipe into zstd 
  cat $i | pbzip2 -m125 -p4 -d | zstd --adapt -o $end_file

  # Calculate end size and time, save as vars
  end_size=$(ls -lah $end_file | awk '{print $5}')
  end_time=$(date '+%H:%M:%S')

 # Print out and tee to log
  echo -e "END:\t${end_file:0:12}... ($end_size)\t\t$end_time\n\n" | tee -a log.txt
done

```

### WHAT??
```
LOG FILE: Bzip2 Before, Zstd after
-----------------------------------
START:	01.02_Frame...  (16G)		  07:19:01 (bzip2)
END:	01.02_Framew...  (3.7G)		  07:32:14 (zstd)

START:	01.03_Comm_.... (9.9G)      07:32:14 (bzip2)
END:	01.03_Comm_C...,  (2.7G)      07:35:40 (zstd)

START:	01.04_Report... (14G)		  07:35:40 (bzip2)
END:	01.04_Report...  (3.2G)		  07:41:00 (zstd)

START:	03.01 - Vuln... (30G)	   	07:41:00 (bzip2)
END:	03.01 - Vuln... ( 5.8G)		  07:52:13 (zstd)

START:	03.01 - Vuln...(1.4G)	    07:52:13 (bzip2)
END:	03.01 - Vuln...  (1.4G)	    07:52:40 (zstd)

START:	04.07 - Soci... (14G)		  07:52:40 (bzip2)
END:	04.07 - Soci...  (3.1G)		  07:59:03 (zstd)

START:	04.08_Wirele... (16G)	    07:59:03 (bzip2)
END:	04.08_Wirele...  (4.1G)		  08:06:08 (zstd)

START:	04.08-DemoA... (5.2G)	    08:06:08 (bzip2)
END:	04.08-DemoA....  (1.6G)		  08:08:24 (zstd)

START:	04.08-DemoB.... (12G)		  08:08:24 (bzip2)
END:	04.08-DemoB....  (2.7G)		  08:13:55 (zstd)

START:	05.03 - Exfi... (21G)		  08:13:55 (bzip2)
END:	05.03 - Exfi...  (4.9G)		  08:22:35 (zstd)

START:	Text Process... (16G)		  08:22:35 (bzip2)
END:	Text Process...  (5.6G)		  08:30:24 (zstd)
```

### Wild...
```
ls -Ahl *.bz2 *.zst | cut -c 28-34,47-60 | sed 's/J//'
  16G 01.02_Framewor
 3.7G 01.02_Framewor
 9.9G 01.03_Comm_Col
 2.7G 01.03_Comm_Col
  14G 01.04_Reportin
 3.2G 01.04_Reportin
  30G 03.01 - Vulner
 5.8G 03.01 - Vulner
 868M 03.03 - Physic
 5.4G 04.03 Host-bas
 2.7G 04.06-Speciali
  14G 04.07 - Social
 3.1G 04.07 - Social
  16G 04.08_Wireless
 4.1G 04.08_Wireless
 5.2G 04.08-DemoA.mo
 1.6G 04.08-DemoA.mo
  12G 04.08-DemoB.mo
 2.7G 04.08-DemoB.mo
  21G 05.03 - Exfil.
 4.9G 05.03 - Exfil.
 1.6G DemoA.mov.zst
  16G Text Processin
 5.6G Text Processin
```
