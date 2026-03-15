#!/system/bin/sh
mkdir -p /data/local/tmp/stratum
LOG=/data/local/tmp/stratum/boot.log
> $LOG
echo "$(date) post-fs-data started" >> $LOG

echo 100 > /sys/class/timed_output/vibrator/enable

MODULE_DIR=/data/adb/modules/boot-menu
export LD_LIBRARY_PATH=$MODULE_DIR/system/lib64:/system/lib64
export LD_PRELOAD=$MODULE_DIR/system/lib64/stub.so

chmod +x $MODULE_DIR/system/bin/stratum_binary
chmod +x $MODULE_DIR/extras/*

# wait for surfaceflinger
(
    until pidof surfaceflinger > /dev/null 2>&1; do
        sleep 0.2
    done
    echo "$(date) surfaceflinger up, launching stratum" >> $LOG
    $MODULE_DIR/system/bin/stratum_binary >> $LOG 2>&1
) &

echo "$(date) done" >> $LOG
