for f in *.png
do
    ./decay -rc $1 --in $f --reduction $2 > /dev/null
done
