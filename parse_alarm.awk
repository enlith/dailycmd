#!/usr/bin/awk -f

BEGIN {
    RS=","
    FS=":"
}

$1 ~ /"alarmTime"/ {
    alarmTime = $2
}

$1 ~ /"alarmPicUrl"/ {
    alarmPicUrl = $2
    for (i = 3; i <= NF; i++) {
        alarmPicUrl = alarmPicUrl ":" $i
        if ($i ~ /"$/) {
            gsub(/"|,$/, "", alarmPicUrl)
            break
        }
    }
}

alarmTime && alarmPicUrl {
    printf("Alarm_Time: %s - Alarm_Pic_URL: %s\n", alarmTime, alarmPicUrl)
    alarmTime = alarmPicUrl = ""
}
