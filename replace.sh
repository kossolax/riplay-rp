#!/bin/bash

find ./ -type f -name "*.sp" -exec sed -i -e 's/TSX-RP/KZG-RP/g' {} \;