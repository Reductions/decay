for f in *.png
do
    for r in 000 022 044 066 088 222 244 266 288 444 466 488 666 688 888
    do
        ./decay -yc --in $f --reduction $r
    done

    for r in 000 222 444 666 888
    do
        ./decay -rc --in $f --reduction $r
    done
done
