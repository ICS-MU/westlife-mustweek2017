#!/bin/bash

if [ `id -u` -ne 0 ]; then
	exec sudo -E /bin/bash -c "$0"
fi

su -s /bin/bash saxs -c "cd /usr/local/saxs/; ./saxsd.sh &"
