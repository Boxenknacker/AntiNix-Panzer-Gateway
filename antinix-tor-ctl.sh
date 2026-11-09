#!/bin/bash
case "$1" in
    start)
        if ! pgrep -x tor > /dev/null; then
            su -s /bin/bash -c "LD_LIBRARY_PATH=/opt/tor /opt/tor/tor -f /opt/tor/etc/tor/torrc &" debian-tor
        fi
        ;;
    stop)
        pkill -x tor 2>/dev/null || true
        ;;
    i2p-start)
        mkdir -p /run/i2pd && chown i2pd:i2pd /run/i2pd && rm -f /run/i2pd/i2pd.pid
        su -s /bin/sh -c "/usr/bin/i2pd --conf=/etc/i2pd/i2pd.conf --datadir=/var/lib/i2pd --pidfile=/run/i2pd/i2pd.pid --daemon" i2pd
        ;;
    i2p-stop)
        start-stop-daemon --stop --quiet --ok-notfound --pidfile /run/i2pd/i2pd.pid ; pkill -x i2pd-daemon 2>/dev/null || true
        ;;
esac
