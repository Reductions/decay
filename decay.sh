for f in *.png
do
    for r in 000 011 033 077 133 177 377
    do
        ./decay -yc --in $f --reduction $r
    done

    for r in 000 111 333 777
    do
        ./decay -rc --in $f --reduction $r
    done
done
