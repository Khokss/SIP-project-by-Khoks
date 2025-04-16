#!/bin/bash

CSV_FILE="reg.csv"
XML_FILE="confa.xml"
SIPP_HOST_IP="185.236.24.236"
REMOTE_HOST="185.236.24.236:5050"
BASE_PORT=5068
SESSION_NAME="sipp_conf"

dos2unix "$CSV_FILE" &>/dev/null


tmux new-session -d -s $SESSION_NAME

i=0
while IFS=";" read -r user ip target; do
  [[ -z "$user" || "$user" == "SEQUENTIAL" ]] && continue

  SIP_PORT=$((BASE_PORT + i))
  CMD="sipp $REMOTE_HOST -sf $XML_FILE -i $SIPP_HOST_IP -p $SIP_PORT -inf <(echo -e \"SEQUENTIAL\n$user;$ip;$target\") -m 1 -aa -trace_rtt -trace_stat -trace_err -trace_msg"

  if [[ $i -eq 0 ]]; then
    tmux send-keys -t $SESSION_NAME "$CMD" C-m
  else
    tmux split-window -t $SESSION_NAME -h
    tmux send-keys -t $SESSION_NAME "$CMD" C-m
  fi

  ((i++))
done < <(tail -n +2 "$CSV_FILE")

tmux select-layout -t $SESSION_NAME tiled
tmux attach-session -t $SESSION_NAME
