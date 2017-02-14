sh decay.sh --huffman 000
sh decay.sh --lzw 000
sh undecay.sh
rm *000*

for red in 000 111 222 333 444 555 666 777 888 999
do
    for enc in --huffman --lzw
    do
        echo ------------------
        echo $red$enc
        echo ------------------
        echo compress time
        echo ------------------
        time sh decay.sh $enc $red
        echo ------------------
        echo decompress time
        echo ------------------
        time sh undecay.sh
        echo ------------------
        echo
        mkdir ./reports/dcy/$red$enc
        mkdir ./reports/png/$red$enc
        mv *$red.png ./reports/png/$red$enc
        mv *$red.dcy ./reports/dcy/$red$enc
    done
 done
