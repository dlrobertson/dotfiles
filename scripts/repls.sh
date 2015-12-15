#!/usr/bin/env zsh

AUTH=0
ENGINE="wiredTiger"
PORT="27017"
NREPL=3
NAME="rs0"
BASE=/data
for i in "$@"; do
    case ${i} in
        --engine=*)
            ENGINE="${i#*=}"
            shift
            ;;
        --auth)
            AUTH=1
            shift
            ;;
        --port=*)
            PORT="${i#*=}"
            shift
            ;;
        --repls=*)
            NREPL="${i#*=}"
            shift
            ;;
        --name=*)
            NAME="${i#*=}"
            shift
            ;;
        --basedir=*)
            BASE="${i#*=}"
            shift
            ;;
        --exit)
            i="0"
            while [ $i -lt $NREPL ]; do
                echo "use admin; db.shutdownServer();" | mongo --port $(($PORT+$i))
                i=$[$i+1]
            done
            exit 0
            ;;
        --help)
            echo "Usage: ./repls.sh <options>"
            echo "\t--engine=<string>\tdatabase engine"
            echo "\t--auth\t\t\tenable authentication"
            echo "\t--port=<int>\t\tstart port to attach instances to"
            echo "\t--nrepls=<int>\t\tnumber of repleca sets"
            echo "\t--name=<string>\t\tbase name to use"
            exit 0
            shift
            ;;
        *)
            echo "Unrecognized option ${i}"
            exit 1
            ;;
    esac
done

filehash=$(date | openssl dgst -sha1 | sed "s/(stdin)= //")
baselogpath="${HOME}/.log/"

filename=~/.tmpfile-${filehash}
touch ${filename}
cat > ${filename} << "EOF"
systemLog:
    destination: file
    logAppend: true
    verbosity: 1 #range from 1 - 5
storage:
    engine: ENGINE
    directoryPerDB: true
    STORAGEOPTS
    journal:
        enabled: true
replication:
    replSetName: NAME
processManagement:
    fork: true
    #pidFilePath: "/var/run/mongodb/mongodb.pid"
net:
    bindIp: 127.0.0.1
    #port: 27017
    wireObjectCheck: true
    unixDomainSocket:
        enabled: false
    http:
        enabled: false
security:
    authorization: AUTH
setParameter:
    enableLocalhostAuthBypass: false
    cursorTimeoutMillis: 900000
EOF

case ${ENGINE} in
    wiredTiger)
        sed -i s/ENGINE/\"wiredTiger\"/ ${filename}
        sed -i s/STORAGEOPTS/"wiredTiger:\n$(printf '%.0s ' {0..7})engineConfig:\n$(printf '%.0s ' {0..11})directoryForIndexes: true\n$(printf '%.0s ' {0..7})collectionConfig:\n$(printf '%.0s ' {0..11})blockCompressor: \"snappy\""/ ${filename}
            ;;
    mmapv1)
        sed -i s/ENGINETYPE/\"wiredTiger\"/g ${filename}
        sed -i s/ENGINE// ${filename}
        ;;
    *)
        echo "Unrecognized engine type: ${ENGINE}"
        exit 1
        ;;
esac

if [ ${AUTH} -gt 0 ]; then
    sed -i "s/AUTH/\"enabled\"/" ${filename}
else
    sed -i "s/AUTH/\"disabled\"/" ${filename}
fi

sed -i "s/NAME/\"$NAME\"/" $filename

i="0"
while [ $i -lt $NREPL ]; do
    tmpport=$(($PORT+${i}))
    tmpname=${NAME}-${i}
    logname=${baselogpath}${tmpname}.log
    datadir=${BASE}/${tmpname}
    if [ ! -d $datadir ]; then
        mkdir -p $datadir
    fi
    if [ ! -f $logname ]; then
        touch $logname
    fi

    mongod -f ${filename} \
        --dbpath $datadir \
        --port ${tmpport} \
        --logpath ${logname}
    i=$[$i+1]
done
rm ${filename}
