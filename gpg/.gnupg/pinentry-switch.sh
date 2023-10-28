#!/bin/bash

if [[ "$(uname)" == "Darwin" ]]; then
    /opt/homebrew/bin/pinentry-mac "$@"
else
    /usr/bin/pinentry-qt "$@"
fi