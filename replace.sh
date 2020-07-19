#!/bin/bash

find ./ -type f -name "*.sp" -exec sed -i -e 's/AcceptEntityInput/rp_AcceptEntityInput/g' {} \;
find ./includes -type f -name "*.inc" -exec sed -i -e 's/AcceptEntityInput/rp_AcceptEntityInput/g' {} \;