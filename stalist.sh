#!/bin/sh

IFNAME=$1

if [ $# -eq 0 ]; then                                                                                               
        echo "Not selected interface"                                                                               
        echo "Usage: stalist.sh <interface>, ex. eth5"                                                              
        exit 0                                                                                                      
fi     

echo " ___________________________________________________________________________________________________________ "  
echo " " 
echo " " 
echo " Basic information: "   
echo " " 
echo "| AID |      Uptime      |     Idle time    |      MAC address     |                  Status (AAA) "

for x in $(wl -i $IFNAME assoclist | cut -d ' ' -f 2);
do
	STA_INFO=$(wl -i $IFNAME sta_info $x)
	AID=$(wl -i $IFNAME sta_info $x | grep aid | awk 'sub(/.*aid:/,"") {print $0}')
	UPTIME=$(wl -i $IFNAME sta_info $x | grep network | awk 'sub(/.*network /,"") {print $0}')
	IDLE=$(wl -i $IFNAME sta_info $x | grep idle | awk 'sub(/.*idle /,"") {print $0}')
	MAC_ADDRESS=$x
	AUTHENTICATED=$(wl -i $IFNAME sta_info $x | grep state: | cut -d' ' -f3) 
	ASSOCIATED=$(wl -i $IFNAME sta_info $x | grep state: | cut -d' ' -f4) 	
	AUTHORIZED=$(wl -i $IFNAME sta_info $x | grep state: | cut -d' ' -f5)
	echo "   $AID      $UPTIME        $IDLE         $MAC_ADDRESS       $AUTHENTICATED $ASSOCIATED $AUTHORIZED " 
done


echo " " 
echo " "                                                                                                                                                                                                    
echo " Noise and RSSI levels: "  
echo " "  
echo "| AID |  Noise floor   |  RSSI (last frame)  |   RSSI (avg.)  "

for x in $(wl -i $IFNAME assoclist | cut -d ' ' -f 2);                                                                                
do                                                                                                                                    
	AID=$(wl -i $IFNAME sta_info $x | grep aid | awk 'sub(/.*aid:/,"") {print $0}') 
        NOISE_FLOOR=$(wl -i $IFNAME sta_info $x | grep noise | awk 'sub(/.*floor:/,"") {print $0}')        
        RSSI_LF=$(wl -i $IFNAME sta_info $x | grep "rssi of last rx" | awk 'sub(/.*frame:/,"") {print $0}' )                                                          
        RSSI_AVG=$(wl -i $IFNAME sta_info $x | grep "average rssi of" | awk 'sub(/.*frames:/,"") {print $0}' )
	echo "  " $AID "  " $NOISE_FLOOR "   " $RSSI_LF  "      " $RSSI_AVG
done 


echo " "                                                                                      
echo " "                                                                                                                                                                                                    
echo " 802.11 mode and flags: "                                                                                                                                                                        
echo " " 
echo "| AID | PHY Mode |  PSM  |  SGI20  |  SGI40  |  STBC-Tx  |  STBC-Rx  |  MIMO-PS  |  MIMO-PS-RTS |  WME  |  AMPDU  |  AMSDU  |  BRCM "

for x in $(wl -i $IFNAME assoclist | cut -d ' ' -f 2);
do
	AID=$(wl -i $IFNAME sta_info $x | grep aid | awk 'sub(/.*aid:/,"") {print $0}')                                                                                                  
        FLAGS=$(wl -i $IFNAME sta_info $x | grep flags | awk 'sub(/.*:/,"") {print $0}')
	FLAGS_HT=$(wl -i $IFNAME sta_info $x | grep 'HT caps' | awk 'sub(/.*:/,"") {print $0}') 
	
	case "$FLAGS" in
	 *HE_CAP*)
		PHY_MODE='802.11ax'
		;;
	 *VHT_CAP*)
		PHY_MODE='802.11ac'
		;;
	 *N_CAP*)
		PHY_MODE='802.11n'
		;;
	*)
		RATESET=$(wl -i $IFNAME sta_info $MAC | awk '/rateset/{split($0,m,"[\]\[]"); print m[2]}')
		PHY_MODE='802.11b'
		
		for r in $RATESET; do
			echo $r
			[ $r -eq 0 ] && break
            		
			if [ $r -gt 11 ]; then
                		CHANNEL=$(wl -i $IFNAME sta_info $MAC | awk '/chanspec/{split($2,m,"/"); print m[1]}')
                		[ $CHANNEL -gt 14 ] && PHY_MODE='802.11a' || PHY_MODE='802.11g'
                		break
            		fi
        	done
  	;;
	esac
	

	case $FLAGS                         
         in *PSM*)                               
                PHY_MODE_PSM="YES"   
        ;;                                  
        *)                                 
                PHY_MODE_PSM=" NO"    
        ;;                                  
        esac
	
	case $FLAGS_HT
	 in *SGI20*)
		PHY_MODE_SGI20="YES"
	;;
	*)
		PHY_MODE_SGI20=" NO"
	;;
	esac

	case $FLAGS_HT                                                                                                
         in *SGI40*)                                                                                                  
                PHY_MODE_SGI40="YES"
        ;;                                                                                                            
        *)                                                                                                            
                PHY_MODE_SGI40=" NO"                                                                                   
        ;;                                                                                                            
        esac

	case $FLAGS
	 in *MIMO-PS*)
		PHY_MODE_MMPS="YES"
	;;
	*)
		PHY_MODE_MMPS=" NO"
	;;
	esac
	                                                                                                                                                                                                                                                              
        case $FLAGS                                                                                                                                                                                                                                                   
         in *MIMO-PS-RTS*)                                                                                                                                                                                                                                                
                PHY_MODE_MMPS_RTS="YES"                                                                                                                                                                                                                                   
        ;;                                                                                                                                                                                                                                                            
        *)                                                                                                                                                                                                                                                            
                PHY_MODE_MMPS_RTS=" NO"                                                                                                                                                                                                                                   
        ;;                                                                                                                                                                                                                                                            
        esac   

	case $FLAGS
	 in *WME*)
		PHY_MODE_WME="YES"
	;;
	*)
		PHY_MODE_WME=" NO"
	;;
	esac

        case $FLAGS
	 in *AMPDU*)
		PHY_MODE_AMPDU="YES"
	;;
	*)
		PHY_MODE_AMPDU=" NO"
	;;
	esac
	
	case $FLAGS
	 in *AMSDU*)
		PHY_MODE_AMSDU="YES"
	;;
	*)
		PHY_MODE_AMSDU=" NO"
	;;
	esac
	
	case $FLAGS 
	 in *BRCM*)
		PHY_MODE_BRCM='YES'
	;;
	*)
		PHY_MODE_BRCM=' NO'
	;;
	esac
	
	case $FLAGS_HT
	 in *STBC-Tx*)
		PHY_MODE_STBC_TX='YES'
	;;
	*)
		PHY_MODE_STBC_TX=' NO'
	;;
	esac
	
	case $FLAGS_HT                                                                                                                                                                                                                                                
         in *STBC-Rx*)                                                                                                                                                                                                                                                  
                PHY_MODE_STBC_RX='YES'                                                                                                                                                                                                                                
        ;;                                                                                                                                                                                                                                                            
        *)                                                                                                                                                                                                                                                            
                PHY_MODE_STBC_RX=' NO'                                                                                                                                                                                                                                 
        ;;                                                                                                                                                                                                                                                            
        esac

	echo "   $AID   $PHY_MODE    $PHY_MODE_PSM      $PHY_MODE_SGI20        $PHY_MODE_SGI40        $PHY_MODE_STBC_TX        $PHY_MODE_STBC_RX          $PHY_MODE_MMPS            $PHY_MODE_MMPS_RTS       $PHY_MODE_WME      $PHY_MODE_AMPDU       $PHY_MODE_AMSDU       $PHY_MODE_BRCM "

done 



echo " "                                                                                                                                                                                                    
echo " "                                                                                                                                                                                                    
echo " Rate and statistics: "                                                                                                                                                                             
echo " "

echo "| AID |   Station Address   |    MCS    |    PHY Mbps  |   Data Mbps   |   Air Use  |   Data Use   |   Retries " 

for x in $(wl -i $IFNAME assoclist | cut -d ' ' -f 2);                                                                                                                                                      
do
	AID=$(wl -i $IFNAME sta_info $x | grep aid | awk 'sub(/.*aid:/,"") {print $0}')
	BSDATA=$(wl -i $IFNAME bs_data | grep $x )
	RATE_TYPE=$(wl -i $IFNAME nrate)
	
	case $RATE_TYPE
	 in *legacy*)
		MCS='legacy'
	;;
	*)
		MCS=$(echo $RATE_TYPE | grep mcs | awk 'sub(/.*index /,"") {print $1}') 
	;;
	esac 

	PHY_MBPS=$(echo $BSDATA | cut -d' ' -f2)
	DATA_MBPS=$(echo $BSDATA | cut -d' ' -f3 )
	AIR_USE=$(echo $BSDATA | cut -d' ' -f4 )
	DATA_USE=$(echo $BSDATA | cut -d' ' -f5 )
	RETRIES=$(echo $BSDATA | cut -d' ' -f6 )

	echo "   $AID    $x      $MCS           $PHY_MBPS          $DATA_MBPS          $AIR_USE         $DATA_USE          $RETRIES " 
done 



echo " "                                                                                                                                                                                                    
echo " "                                                                                                                                                                                                    
echo " Traffic statistics: "                                                                                                                                                                               
echo " "                                                                                                                                                                                                    
                                                                                                                                                                                                            
echo "| AID |    MAC address    | Tx bcast/mcast pkts | Tx bcast/mcast bytes | Tx ucast pkts | Tx ucast bytes | Tx total pckts | Tx total Mbytes "   
                                                                                                                                                                                                            
for x in $(wl -i $IFNAME assoclist | cut -d ' ' -f 2);                                                                                                                                                      
do                                                                                                                                                                                                          
        AID=$(wl -i $IFNAME sta_info $x | grep aid | awk 'sub(/.*aid:/,"") {print $0}')                                                                                                                     

	TX_BMCAST_PKT=$(wl -i $IFNAME sta_info $x | grep "tx mcast/bcast pkts" | awk 'sub(/.*pkts: /,"") {print $0}')
	TX_BMCAST_BYTES=$(wl -i $IFNAME sta_info $x | grep "tx mcast/bcast bytes" | awk 'sub(/.*bytes:/,"") {print $0}')
	TX_UCAST_PKT=$(wl -i $IFNAME sta_info $x | grep "tx ucast pkts" | awk 'sub(/.*pkts:/,"") {print $0}')
	TX_UCAST_BYTES=$(wl -i $IFNAME sta_info $x | grep "tx ucast bytes" | awk 'sub(/.*bytes:/,"") {print $0}')
	TX_TOTAL_PKT=$(wl -i $IFNAME sta_info $x | grep "tx total pkts" | awk 'sub(/.*pkts:/,"") {print $0}')
	TX_TOTAL_BYTES=$(wl -i $IFNAME sta_info $x | grep "tx total bytes" | awk 'sub(/.*bytes:/,"") {print $0}')                                                                                                                                                                                                          
	echo "   $AID   $x        $TX_BMCAST_PKT              $TX_BMCAST_BYTES           $TX_UCAST_PKT         $TX_UCAST_BYTES      $TX_TOTAL_PKT        $TX_TOTAL_BYTES        "                                                                       
done    



echo " " 
echo "| AID |    MAC address    | Rx bcast/mcast pkts | Rx bcast/mcast bytes | Rx ucast pkts | Rx ucast bytes | Rx total pckts | Rx total Mbytes "                                                          
                                                                                                                                                                                                            
for x in $(wl -i $IFNAME assoclist | cut -d ' ' -f 2);                                                                                                                                                      
do                                                                                                                                                                                                          
        AID=$(wl -i $IFNAME sta_info $x | grep aid | awk 'sub(/.*aid:/,"") {print $0}')                                                                                                                     
                                                                                                                                                                                                            
        RX_BMCAST_PKT=$(wl -i $IFNAME sta_info $x | grep "rx mcast/bcast pkts" | awk 'sub(/.*pkts: /,"") {print $0}')                                                                                       
        RX_BMCAST_BYTES=$(wl -i $IFNAME sta_info $x | grep "rx mcast/bcast bytes" | awk 'sub(/.*bytes:/,"") {print $0}')                                                                                    
        RX_UCAST_PKT=$(wl -i $IFNAME sta_info $x | grep "rx ucast pkts" | awk 'sub(/.*pkts:/,"") {print $0}')                                                                                               
        RX_UCAST_BYTES=$(wl -i $IFNAME sta_info $x | grep "rx ucast bytes" | awk 'sub(/.*bytes:/,"") {print $0}')                                                                                           
        RX_TOTAL_PKT=$(wl -i $IFNAME sta_info $x | grep "rx data pkts" | awk 'sub(/.*pkts:/,"") {print $0}')                                                                                               
        RX_TOTAL_BYTES=$(wl -i $IFNAME sta_info $x | grep "rx data bytes" | awk 'sub(/.*bytes:/,"") {print $0}')                                                                                           
                                                                                                                                                                                                            
        echo "   $AID   $x           $RX_BMCAST_PKT                     $RX_BMCAST_BYTES           $RX_UCAST_PKT         $RX_UCAST_BYTES         $RX_TOTAL_PKT        $RX_TOTAL_BYTES        "                           
done





echo " "                                                                                                                                                                                                    
echo " "
echo " ___________________________________________________________________________________________________________ " 
echo " "  
