#!/data/data/berserker.android.apps.sshdroid/home/.bin/sh
# This script records an RTSP stream in segments and deletes old recordings.
# To stop the script before the next loop iteration, send the SIGUSR1 signal to the script's process ID (PID) using one of the following commands:
# kill -10 PID
# pkill -10 scriptname


#read -s -p "Enter the RTSP stream password: " password
#echo

stream_url="rtsp://<user>:<secretcode>@<cameraip>:554"
segment_duration=300
output_directory="/storage/external_storage/sda2/homeNVR"
timestamp_format="%Y-%m-%d_%H-%M-%S"
keep_days=1
ffmpeg_binary="/data/data/com.ma7moud3ly.ffmpegdroid/ffmpeg"


# Function to handle the SIGUSR1 signal
handle_signal() {
    echo "Received SIGUSR1 signal. Stopping the script..."
    exit 0
}

# Register the signal handler
trap handle_signal SIGUSR1

while true; do
    current_date=$(date +"%Y-%m-%d")
    output_folder="${output_directory}/${current_date}"
    mkdir -p "$output_folder"
    output_file="${output_folder}/output_$(date +"${timestamp_format}").mp4"
    log_file="${output_folder}/ffmpeg_panic.log"
    nohup "$ffmpeg_binary" -loglevel panic -fflags +genpts -i "$stream_url" -c:v copy -c:a copy -t "$segment_duration" "$output_file" >> "$log_file"

    # Delete old folders
    current_time=$(date +%s)
    for folder in "$output_directory"/*; do
        if [ -d "$folder" ]; then
            folder_timestamp=$(date -r "$folder" +%s)
            if [ "$((current_time - folder_timestamp))" -gt "$((keep_days * 24 * 60 * 60))" ]; then
                rm -rf "$folder"
            fi
        fi
    done

done
