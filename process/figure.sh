function geometry {

if  [ -e $RESULTDIR ]; then
  rm $FIGUREFILE
  touch $FIGUREFILE
  for dname in r1geometry.xyz r2geometry.xyz rcgeometry.xyz tsgeometry.xyz pgeometry.xyz ircgeometry.xyz
  do
    if  [ -f $RESULTDIR/$dname ]; then
          if [ -s $RESULTDIR/$dname ]; then
            if [ ! -d $RESULTDIR/"${dname%.xyz}" ]; then
              mkdir $RESULTDIR/"${dname%.xyz}"
              cp $RESULTDIR/$dname $RESULTDIR/"${dname%.xyz}"1.xyz
              mv $RESULTDIR/"${dname%.xyz}"1.xyz $RESULTDIR/"${dname%.xyz}"
              echo $RESULTDIR/"${dname%.xyz}"/"${dname%.xyz}"1 >> $RESULTDIR/changefile.txt
            else
              fileNum="$( ls -1q $RESULTDIR/"${dname%.xyz}" | wc -l )"
              fileNum=`echo $fileNum |awk '{printf"%4.0f", ($1-1)/2}'`
              fileNum=`expr $fileNum`
              if cmp -s "$RESULTDIR/$dname" $RESULTDIR/"${dname%.xyz}"/"${dname%.xyz}"$fileNum.xyz; then
                true
              else
                fileNum=`expr $fileNum + 1`
                cp $RESULTDIR/$dname $RESULTDIR/"${dname%.xyz}"$fileNum.xyz
                mv $RESULTDIR/"${dname%.xyz}"$fileNum.xyz  $RESULTDIR/"${dname%.xyz}"
                echo $RESULTDIR/"${dname%.xyz}"/"${dname%.xyz}"$fileNum >> $RESULTDIR/changefile.txt
              fi
            fi
          fi
    fi
  done
fi
}

RESULTDIR="$( pwd -P )"
FIGUREFILE="$RESULTDIR/changefile.txt"

geometry


SCM_OFFSCREEN=1 SCM_GUITEST=$PYFRAGHOME/process/adfpicture.tcl adfinput $FIGUREFILE


while IFS= read -r var
do
  python3 $PYFRAGHOME/process/img2video.py -d "$(dirname $var)"  -o video.mp4 -e png
  mv video.mp4 "$(dirname $var)"
done < "$FIGUREFILE"
