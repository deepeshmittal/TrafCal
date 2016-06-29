#########################################################################################################  
#     
# Created By - Deepesh Mittal 			                                                        #  
#                                                                                                       #  
# Description - TrafCal (traffic calculator) is designed for calculating incoming and outgoing traffic  #  
#       from any Linux box. Incoming/Outgoing traffic will be measured in terms of data byte    #  
#       transfer rate (in Mbps) and Ethernet frame or IP packets arriving/leaving to Linux box. #  
#       Basically it collect raw information from standard Linux counters and does MB and Mbps  #  
#       conversions on collected information for user and display that information in processed #  
#       form. Since it is a simple bash script can be use on any Linux box without installing   #  
#       any other package.                                  #  
#                                                   #  
#       This tool also displays data in real-time fashion. In this option, user will get    #   
#       traffic information in Mbps and number of packets arriving/receiving in real-time   #  
#       manner which can also be captured by pressing "enter" with timestamp for later      #  
#       references.                                     #  
#                                                   #  
#                                                   #  
# Prerequisites - Run this tool as a "root" user                            #  
#       - Before running this tool check whether statistic (rxbyte/txbyte/rxpacket/txpacket)    #  
#         are present under directory structure /sys/class/net/<if_name>/statistics.      #  
#         If not, find the appropriate directory structure and store that in DIR variable.  #  
#       - RT_FREQ stores frequency with which data will displayed, change according to your     #  
#         requirements(default is 200 msec).                            #  
#                                                   #  
#########################################################################################################  
  
#!/bin/bash  
  
################################################################################  
# Constants / Globals  
################################################################################  
  
COUNT=$#  
TIME=3  
ARGS=0  
ARG_1=$1  
DEF_TIME=3  
DIR="/sys/class/net/$3/statistics"  
RT_FREQ=.2  
MUL=$(awk 'BEGIN{ print '1'/'$RT_FREQ' }')  
  
################################################################################  
# Display Banner  
################################################################################  
  
function banner {  
    printf "\n"  
    printf "******************************************************************************************\n"  
    printf "*                         Welcome to Traffic Calculator (trafcal)                        *\n"  
    printf "******************************************************************************************\n"  
}  
  
################################################################################  
# Display help and various options of tool.  
################################################################################  
  
function show_help {  
    printf "trafcal 1.0 \n"  
    printf "\n"  
    printf "Usage: trafcal.sh -h (print the help information)\n"  
    printf "       trafcal.sh -[TR] [options]\n"  
    printf "\n"  
    printf "Commands:\n"  
    printf "\n"  
    printf "  -R   Calcution of receive data on particular interface\n"  
    printf "  -T   Calcution of Transmit data on particular interface\n"  
    printf "\n"  
    printf "Options:\n"  
    printf "  -b <if_name>             Average Traffic Receive/Transmit (in Mbps)\n"  
    printf "  -B <if_name> -s <time>   Traffic Received/Transmitted for particular time duration\n"  
    printf "  -p <if_name>             Average packets (in packets/s) Receive/Transmit \n"  
    printf "  -P <if_name> -s <time>   Packets Receive/Transmit in paticular time interval\n"  
    printf "\n"  
    printf "Real time data options\n"  
    printf "  -Z <if_name>             Traffic Receive/Transmit (in Mbps)\n"  
    printf "  -Y <if_name>             Packets Receive/Transmit\n"  
    printf "\n"  
}  
  
################################################################################  
# Calculate and display traffic in Mbps and MB.   
################################################################################  
  
function get_traf_log {  
sleep 1  
time=$2  
  
if [ -f "/tmp/counter1.txt" ]  
        then  
                rm /tmp/counter1.txt  
fi  
  
if [ $ARG_1 = "-R" ]  
then  
cat ${DIR}/rx_bytes > /tmp/counter1.txt  
else  
cat ${DIR}/tx_bytes > /tmp/counter1.txt  
fi  
  
byterecv_1=`echo $(sed -n 1p /tmp/counter1.txt)`  
rm /tmp/counter1.txt  
  
if [ "$2" = $DEF_TIME ]  
then  
        printf "\n"  
        printf "Calculating traffic on $1"  
else  
        printf "\n"  
        printf "Calculating traffic on $1 for $2 Secs"  
fi  
while [ "$time" -ne 0 ]; do  
        printf "."  
        sleep 1  
        time=`expr $time - 1`  
done  
  
printf "\n"  
  
if [ $ARG_1 = "-R" ]  
then  
cat ${DIR}/rx_bytes > /tmp/counter1.txt  
else  
cat ${DIR}/tx_bytes > /tmp/counter1.txt  
fi  
  
byterecv_2=`echo $(sed -n 1p /tmp/counter1.txt)`  
rm /tmp/counter1.txt  
  
diff_bytes=`expr $byterecv_2 - $byterecv_1`  
diff_bytes=$(awk 'BEGIN{ print '$diff_bytes'/1024 }')  
diff_bytes=$(awk 'BEGIN{ print '$diff_bytes'/1024 }')  
  
speed=$(awk 'BEGIN{ print '$diff_bytes'*8 }')  
speed=$(awk 'BEGIN{ print '$speed'/'$2' }')  
  
printf "\n"  
sleep 1  
printf "Calculation Completed !! Below are the results:\n"  
printf "\n"  
sleep 2  
if [ "$2" = $DEF_TIME ]  
then  
        printf "**************************************************************************\n"  
        printf "Interface       : $1\n"  
        printf "Average Traffic : $speed Mbps\n"  
        printf "**************************************************************************\n"  
else  
        printf "**************************************************************************\n"  
        printf "Interface     : $1\n"  
        printf "Duration      : $2 secs\n"  
        if [ $ARG_1 = "-R" ]  
        then  
                printf "Data Receive  : $diff_bytes MB\n"  
        else  
                printf "Data Transmit : $diff_bytes MB\n"  
        fi  
        printf "Speed         : $speed Mbps\n"  
        printf "**************************************************************************\n"  
fi  
  
}  
  
################################################################################  
# Calculate and display number of packets send/receive.  
################################################################################  
  
function get_packet_log {  
  
sleep 1  
time=$2  
  
if [ -f "/tmp/counter1.txt" ]  
        then  
                rm /tmp/counter1.txt  
fi  
  
if [ $ARG_1 = "-R" ]  
then  
cat ${DIR}/rx_packets > /tmp/counter1.txt  
else  
cat ${DIR}/tx_packets > /tmp/counter1.txt  
fi  
  
packetrecv_1=`echo $(sed -n 1p /tmp/counter1.txt)`  
rm /tmp/counter1.txt  
  
if [ "$2" = $DEF_TIME ]  
then  
        printf "\n"  
        printf "Calculating average packets receive/transmit on $1"  
else  
        printf "\n"  
        printf "Calculating packets receive/transmit on $1 in $2 Secs"  
fi  
while [ "$time" -ne 0 ]; do  
        printf "."  
        sleep 1  
        time=`expr $time - 1`  
done  
  
printf "\n"  
  
if [ $ARG_1 = "-R" ]  
then  
cat ${DIR}/rx_packets > /tmp/counter1.txt  
else  
cat ${DIR}/tx_packets > /tmp/counter1.txt  
fi  
  
packetrecv_2=`echo $(sed -n 1p /tmp/counter1.txt)`  
rm /tmp/counter1.txt  
  
diff_packet=`expr $packetrecv_2 - $packetrecv_1`  
  
speed=$(awk 'BEGIN{ print '$diff_packet'/'$2' }')  
printf "\n"  
sleep 1  
printf "Calculation Completed !! Below are the results:\n"  
printf "\n"  
sleep 2  
if [ "$2" = $DEF_TIME ]  
then  
        printf "**************************************************************************\n"  
        printf "Interface                : $1\n"  
        if [ $ARG_1 = "-R" ]  
        then  
                printf "Average Packets Receive  : $speed packets/sec\n"  
        else  
                printf "Average Packets Transmit : $speed packets/sec\n"  
        fi  
        printf "**************************************************************************\n"  
else  
        printf "**************************************************************************\n"  
        printf "Interface                : $1\n"  
        printf "Duration                 : $2 secs\n"  
        if [ $ARG_1 = "-R" ]  
        then  
                printf "Packets Receive          : $diff_packet packets\n"  
        else  
                printf "Packets Transmit         : $diff_packet packets\n"  
        fi  
        printf "Average packets Received : $speed packets/sec\n"  
        printf "**************************************************************************\n"  
fi  
}  
  
################################################################################  
# Validations  
################################################################################  
  
function error_message {  
  
printf "\n"  
sleep 1  
printf "Invalid option... use command './trafcal.sh -h' for help \n"  
exit 0  
}  
  
function error_message_1 {  
  
printf "\n"  
sleep 1  
printf "Invalid number of arguments passed... use command './trafcal.sh -h' for help \n"  
exit 0  
}  
  
function error_message_2 {  
  
printf "\n"  
sleep 1  
printf "Error: Wrong argument 4 :- Use -s option for providing time in secs. \n"  
exit 0  
}  
  
function validate_interface {  
  
cd ${DIR}  
  
if [ $? -ne 0 ]  
then  
        printf "\n"  
        sleep 1  
        printf "Error: Wrong argument 3 :- Invalid inerface or statistics not available.\n"  
        exit 0  
fi  
cd - > /dev/null  
}  
  
function validate_int {  
  
re='^[0-9]+$'  
if ! [[ $1 =~ $re ]] ; then  
   printf "\n"  
   sleep 1  
   echo "Error: Wrong argument 5 :- seconds value should be integer \n"  
   exit 0  
fi  
}  
  
################################################################################  
# Calculate traffic and displays the data in real time manner    
################################################################################  
  
function realtime_traffic {  
  
printf "\n"  
printf "\n"  
  
sleep 1  
  
printf "Hit Enter at any moment for capturing data along with time stamp...!! Cntrl + c to exit \n "  
printf "\n"  
sleep 3  
  
printf "Starting real-time traffic monitor !!! \n "  
printf "\n"  
  
while [ 1 ]; do  
  
    if [ $ARG_1 = "-R" ]  
    then  
        cat ${DIR}/rx_bytes > /tmp/counter1.txt  
    else  
        cat ${DIR}/tx_bytes > /tmp/counter1.txt  
    fi  
    byterecv_1=`echo $(sed -n 1p /tmp/counter1.txt)`  
    rm /tmp/counter1.txt  
  
    sleep $RT_FREQ  
  
    if [ $ARG_1 = "-R" ]  
    then  
        cat ${DIR}/rx_bytes > /tmp/counter1.txt  
    else  
        cat ${DIR}/tx_bytes > /tmp/counter1.txt  
    fi  
    byterecv_2=`echo $(sed -n 1p /tmp/counter1.txt)`  
    rm /tmp/counter1.txt  
  
    diff_bytes=`expr $byterecv_2 - $byterecv_1`  
    diff_bytes=$(awk 'BEGIN{ print '$diff_bytes'/1024 }')  
    diff_bytes=$(awk 'BEGIN{ print '$diff_bytes'/1024 }')  
  
    speed=$(awk 'BEGIN{ print '$diff_bytes'*8 }')  
    speed=$(awk 'BEGIN{ print '$speed'*'$MUL' }')  
  
    date +"%T" > /tmp/counter1.txt  
    TIME=`echo $(sed -n 1p /tmp/counter1.txt)`  
    rm /tmp/counter1.txt  
  
    printf '\r%s %s = %1f %s' "$TIME : " "Traffic speed" "$speed" " Mbps."  
done  
printf '\n'  
}  
  
################################################################################  
# Calculate packets send/receive and displays the data in real time manner  
################################################################################  
  
function realtime_packet {  
temp=1  
  
printf "\n"  
printf "\n"  
sleep 1  
  
printf "Hit Enter at any moment for captuirng data along with time stamp...!! Cntrl + c to exit \n "  
printf "\n"  
sleep 3  
  
printf "Starting real-time packet monitor !!! \n "  
printf "\n"  
  
while [ $temp = 1 ]; do  
  
    if [ $ARG_1 = "-R" ]  
    then  
        cat ${DIR}/rx_packets > /tmp/counter1.txt  
    else  
        cat ${DIR}/tx_packets > /tmp/counter1.txt  
    fi  
    byterecv_1=`echo $(sed -n 1p /tmp/counter1.txt)`  
    rm /tmp/counter1.txt  
  
    sleep $RT_FREQ  
  
    if [ $ARG_1 = "-R" ]  
    then  
        cat ${DIR}/rx_packets > /tmp/counter1.txt  
    else  
        cat ${DIR}/tx_packets > /tmp/counter1.txt  
    fi  
    byterecv_2=`echo $(sed -n 1p /tmp/counter1.txt)`  
    rm /tmp/counter1.txt  
  
    diff_bytes=`expr $byterecv_2 - $byterecv_1`  
  
    speed=`expr $diff_bytes \* 5`  
  
    date +"%T" > /tmp/counter1.txt  
    TIME=`echo $(sed -n 1p /tmp/counter1.txt)`  
    rm /tmp/counter1.txt  
  
    printf '\r%s %s %1d %s' "$TIME : " "Packet Receive/Transmit speed... " "$speed" "packets."  
done  
printf '\n'  
}  
  
################################################################################  
# Main  
################################################################################  
  
banner  
  
if [ $COUNT = 0 ]; then  
    show_help  
    exit 1  
fi  
  
while getopts hRT OPT; do  
  
        if [ $ARG_1 = "-h" ]  
        then  
  
            ARGS=1  
            if [ "$COUNT" -ne 1 ]  
            then  
                printf "\n"  
                sleep 1  
                printf "No More arguments required while using -h option.\n"  
                exit 0  
            fi  
            show_help  
            exit 0  
  
  
        elif [ $ARG_1 = "-T" ] || [ $ARG_1 = "-R" ]  
        then  
  
        if [ "$COUNT" == 1 ]  
        then  
                error_message_1  
                exit 0  
        fi  
  
        if [ $2 = "-b" ]  
        then  
            ARGS=1  
            if [ "$COUNT" -ne 3 ]  
            then  
                error_message_1  
                exit 0  
            else  
                validate_interface $3  
                get_traf_log $3 "$TIME"  
                exit 0  
            fi  
  
        fi  
  
        if [ $2 = "-B" ]  
        then  
            ARGS=1  
            if [ "$COUNT" -ne 5 ]  
            then  
                error_message_1  
                exit 0  
            fi  
            if [ $4 != "-s" ]  
            then  
                error_message_2  
                exit 0  
            fi  
  
            validate_interface $3  
            validate_int $5  
            TIME=$5  
            get_traf_log $3 "$TIME"  
            exit 0  
  
        fi  
  
        if [ $2 = "-p" ]  
        then  
            ARGS=1  
            if [ "$COUNT" -ne 3 ]  
            then  
                error_message_1  
                exit 0  
            else  
                validate_interface $3  
                get_packet_log $3 "$TIME"  
                exit 0  
            fi  
  
        fi  
  
        if [ $2 = "-P" ]  
        then  
            ARGS=1  
            if [ "$COUNT" -ne 5 ]  
            then  
                error_message_1  
                exit 0  
            fi  
            if [ $4 != "-s" ]  
            then  
                error_message_2  
                exit 0  
            fi  
  
            validate_interface $3  
            validate_int $5  
            TIME=$5  
            get_packet_log $3 "$TIME"  
            exit 0  
  
        fi  
  
  
        if [ $2 = "-Z" ]  
        then  
            ARGS=1  
            if [ "$COUNT" -ne 3 ]  
            then  
                error_message_1  
                exit 0  
            fi  
            validate_interface $3  
            realtime_traffic $3  
            exit 0  
  
        fi  
  
        if [ $2 = "-Y" ]  
        then  
            ARGS=1  
            if [ "$COUNT" -ne 3 ]  
            then  
                error_message_1  
                exit 0  
            fi  
            validate_interface $3  
            realtime_packet $3  
            exit 0  
  
        fi  
  
        else  
            printf "Invalid option\n"  
            exit 2  
        fi  
done  
  
if [ $ARGS = 0 ]  
then  
error_message  
fi  
