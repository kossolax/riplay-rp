#!/bin/bash

find ./ -type f -name "*.sp" -exec sed -i -e 's/{lightblue}\[TSX-RP\]{default}/" ...MOD_TAG... "/g' {} \;
find ./ -type f -name "*.inc" -exec sed -i -e 's/{lightblue}\[TSX-RP\]{default}/" ...MOD_TAG... "/g' {} \;
