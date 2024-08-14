#!/bin/bash

if [[ "$(uname)" == "Darwin" ]]; then
    /opt/homebrew/bin/pinentry-mac "$@"
else
    /usr/bin/pinentry-gnome3 "$@"
    # /usr/bin/pinentry-qt "$@"
fi