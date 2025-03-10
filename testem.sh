#!/bin/bash

LOG_FILE="/var/log/monitoring.log"
MONITORING_URL="https://test.com/monitoring/test/api"
PROCESS_NAME="test"
LAST_PID_FILE="/tmp/last_pid_test"

log_message() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
}

current_pid=$(pgrep -f $PROCESS_NAME)

if [ -n "$current_pid" ]; then
    if [ -f $LAST_PID_FILE ]; then
        last_pid=$(cat $LAST_PID_FILE)
        if [ "$current_pid" != "$last_pid" ]; then
            log_message "Процесс $PROCESS_NAME был перезапущен. Новый PID: $current_pid"
        fi
    fi

    echo $current_pid > $LAST_PID_FILE

    response=$(curl -s -o /dev/null -w "%{http_code}" $MONITORING_URL)
    if [ "$response" -ne 200 ]; then
        log_message "Сервер мониторинга недоступен. Код ответа: $response"
    fi
else
    if [ -f $LAST_PID_FILE ]; then
        rm $LAST_PID_FILE
    fi
fi
