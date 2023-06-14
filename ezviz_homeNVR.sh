# This script records an RTSP stream in segments and deletes old recordings.
# To stop the script before the next loop iteration, send the SIGUSR1 signal to the script's process ID (PID) using one of the following commands:
# kill -10 PID
# pkill -10 scriptname


#read -s -p "Enter the RTSP stream password: " password
#echo
#
#The content of camera_secret.sh should looks like:
# export USER="your_username"
# export SECRET_CODE="your_secret_code"
# export CAMERA_IP="your_camera_ip"
# export APPKEY="app_key"
# export APPSECRET="app_secret"
# export DEVICE_SERIAL="your_device_id"
# cache expiration time on file expiration.txt, and set to expiration_time
source ./camera_secret.sh

stream_url="rtsp://$USER:$SECRET_CODE@$CAMERA_IP:554"
segment_duration=300
output_directory="/storage/external_storage/sda2/homeNVR"
timestamp_format="%Y-%m-%d_%H-%M-%S"
keep_days=7
ffmpeg_binary="/data/data/com.ma7moud3ly.ffmpegdroid/ffmpeg"
#use worldtiemapi since local time might not accurate in old box
local_nw_time_source="http://worldtimeapi.org/api/timezone/Europe/Stockholm.txt"


# Function to handle the SIGUSR1 signal
handle_signal() {
    echo "Received SIGUSR1 signal. Stopping the script..."
    exit 0
}

# Register the signal handler
trap handle_signal SIGUSR1

while true; do
    # Check if the access token is expired
    if [[ -f "expiration.txt" ]] && [[ $expiration_time -lt $(cat "expiration.txt") ]]; then
    then
        source ./camera_secret.sh
    fi     

    # use real time from network to avoid wrong localtime problem
    currentTimestamp=$(echo -n $(curl -s \
        http://worldtimeapi.org/api/timezone/Etc/UTC.txt \
        | awk -F: '/^unixtime/ {print $2}'))
    # use workaround , since it looks having 6 hours shift(21600s) in timestamp presenting
    devicecurTimestamp=$(expr $currentTimestamp - 21600)
    # read local time from network, stockholm timezone
    current_date=$(curl -s $local_nw_time_source |\
      sed -n 's/^datetime: \(.*\)/\1/p' | awk -F'[-:T]' '{ printf "%s-%02d-%02d\n", $1, $2, $3 }')
    #current_date=$(date -d @$currentTimestamp +"%Y-%m-%d")
    output_folder="${output_directory}/archieve/${current_date}"
    mkdir -p "$output_folder"
    # read local time from network, stockholm timezone
    stockholm_time=$(curl -s $local_nw_time_source |\
      sed -n 's/^datetime: \(.*\)/\1/p' |\
      awk -F'[-:T]' '{ printf "%s-%02d-%02d_%02d-%02d-%02d\n", $1, $2, $3, $4, $5, int($6) }')
    output_file="${output_folder}/output_${stockholm_time}.mp4"
    log_file="${output_folder}/ffmpeg_panic.log"
    #"$ffmpeg_binary" -fflags +genpts -i "$stream_url" -c:v copy -c:a copy -t "$segment_duration" "$output_file" >> "$log_file"
    nohup "$ffmpeg_binary" -loglevel panic -fflags +genpts -i "$stream_url" -c:v copy -c:a copy -t "$segment_duration" "$output_file" >> "$log_file"


    #fetch alarm list from api server
    #busybox does not support milliseconds format
    start_time=$(echo $devicecurTimestamp| awk '{printf "%s000\n", $0}')
    dev_s_time=$devicecurTimestamp
    end_time=""
    alarm_type=-1
    status=2
    page_start=0
    page_size=10
    alarms=$(curl -k -s -X POST -H "Content-Type: application/x-www-form-urlencoded" -d \
      "accessToken=$ACCESS_TOKEN&deviceSerial=$DEVICE_SERIAL&startTime=$dev_s_time&endTime=$end_time&alarmType=$alarm_type&status=$status&pageStart=$page_start&pageSize=$page_size" "https://open.ys7.com/api/lapp/alarm/list" \
      | awk -f parse_alarm.awk)

    # Loop over each line of the output
    alarm_triggered=false
    alarm_folder="${output_directory}/alarm/${current_date}"
    while IFS= read -r line; do
    # Extract the values of Alarm_Time and Alarm_Pic_URL from the line using awk or other string manipulation
      Alarm_Time=$(echo -n "$line" | awk -F ' - ' '{print $1}' | cut -d ' ' -f 2)
      Alarm_Pic_URL=$(echo -n "$line" | awk -F ' - ' '{print $2}' | cut -d ' ' -f 2)

      # check if there is alarm triggered during recording period
      if [[ -n "$Alarm_Time" ]] && (( Alarm_Time > start_time )); then
          echo "Alarm Time: $Alarm_Time" >> "$log_file"
          echo "Alarm Pic URL: $Alarm_Pic_URL" >> "$log_file"
          mkdir -p "$alarm_folder"
          # add 28800 seconds/8 hours as workaround, to be investigated
          filename=$(date -d @$(expr $Alarm_Time / 1000 + 28800) +"%Y-%m-%d_%H-%M-%S")
          # Alarm(s) in recording period, save picture(s)
          echo "save pic ${alarm_folder}/${filename}.jpg" >> "$log_file"
          curl -k -s "$Alarm_Pic_URL" -o "${alarm_folder}/${filename}.jpg"
          alarm_triggered=true
      fi
    done <<< "$alarms"

    # alarm triggered, save record video file
    if "$alarm_triggered"; then
        keep_file="${alarm_folder}/output_${stockholm_time}.mp4"
        echo "rename video $output_file to $keep_file" >> "$log_file"
        mv "$output_file" "$keep_file"
    fi


    # Delete old folders
    current_time=$(date +%s)
    for folder in "$output_directory/archieve"/*; do
        if [ -d "$folder" ]; then
            folder_timestamp=$(date -r "$folder" +%s)
            if [ "$((current_time - folder_timestamp))" -gt "$((keep_days * 24 * 60 * 60))" ]; then
                rm -rf "$folder"
            fi
        fi
    done

done
