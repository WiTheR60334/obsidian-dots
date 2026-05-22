#!/bin/bash

active_pid=$(hyprctl activewindow -j | jq -r '.pid')

[ -n "$active_pid" ] && kill -9 "$active_pid"