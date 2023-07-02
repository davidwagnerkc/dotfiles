#!/bin/sh

JL='~/git/notebooks/'
PORT='9090'
DEV='~/git/'

tmux new-session -d -s jl "cd $JL && jupyter lab --no-browser --port $PORT"
tmux new-session -d -s dev
tmux send-keys "cd $REPO" "C-m"
tmux -2 attach-session -t dev
