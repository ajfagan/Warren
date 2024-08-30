
case $1 in
  server)
    case $2 in
      init)
	;;
      run)
	;;
      *)
	echo "Invalid option: $2";;
    esac
    ;;
  *)
    echo "Invalid option: $opt";;
esac


mkdir .warren-server 

export WARREN_SERVER_DIR=$PWD/.warren-server 

export PGDATA=$WARREN_SERVER_DIR/migrations

trap \ 
  "
    pg_ctl -D $PGDATA stop
    cd $PWD
    rm -rf $WARREN_SERVER_DIR 
  " \
  EXIT

if ! test -d $PGDATA/*Warren.db
then
  diesel migration generate Warren.db
  cp ${config.system.build.toplevel}/boot
fi 

cargo watch -x run
