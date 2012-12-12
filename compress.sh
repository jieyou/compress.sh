#/bin/bash
SRC_PATH=$1;

GIF2PNG=$2;

[ -z $SRC_PATH ] && echo "the img source path is not set " && exit 0;

[ -z $GIF2PNG ] && echo "the one-frame gif will not be turn to png by default"

for img in `find $SRC_PATH -name "*.jpg" `
  do
      original=`ls -l $img |awk '{print $5}'`
      jpegtran -copy none -optimize $img > tmp.jpg
      compressed=`ls -l tmp.jpg |awk '{print $5}'`
      ratio=`gawk -v y=$original -v x=$compressed 'BEGIN{printf "%.2f%%",x*100/y}'`;
      echo "$img compress ratio is $ratio "
      mv -f tmp.jpg $img
done

for img in `find $SRC_PATH -name "*.jpeg" `
  do
      original=`ls -l $img |awk '{print $5}'`
      jpegtran -copy none -optimize $img > tmp.jpg
      compressed=`ls -l tmp.jpeg |awk '{print $5}'`
      ratio=`gawk -v y=$original -v x=$compressed 'BEGIN{printf "%.2f%%",x*100/y}'`;
      echo "$img compress ratio is $ratio "
      mv -f tmp.jpeg $img
done
for img in `find $SRC_PATH -name "*.png" `
  do
      original=`ls -l $img |awk '{print $5}'`
      pngcrush -rem alla -brute -reduce $img tmp.png &>/dev/null 
      mv -f tmp.png $img
      compressed=`ls -l $img |awk '{print $5}'`
      ratio=`gawk -v y=$original -v x=$compressed 'BEGIN{printf "%.2f%%",x*100/y}'`;
      echo "$img  compress ratio is $ratio "
done

for file in `find $SRC_PATH -name "*.gif"`;
 do
   filename=`basename $file`

   suffix=`echo $filename | awk -F. '{print $1}'`

   ret=`identify -format %m $file`;

  if [ "$ret" == "GIF" -a "$GIF2PNG" == "gif2png" ]
     then
       
      convert $file newname.png
      pngcrush -rem alla -brute -reduce newname.png newcrush.png  &>/dev/null
      original=`ls -l $file |awk '{print $5}'`
     compressed=`ls -l newcrush.png |awk '{print $5}'`
     ratio=`gawk -v y=$original -v x=$compressed 'BEGIN{printf "%.2f%%",x*100/y}'`;
     echo "$file  convert to png;compress ratio is $ratio"           
     
     rm -f newname.png $file
     mv -f newcrush.png ${suffix}.png
     mv ${suffix}.png $SRC_PATH/
  else
         gifsicle -O2 $file > tmp.gif
     original=`ls -l $file |awk '{print $5}'`
     compressed=`ls -l tmp.gif |awk '{print $5}'`
     ratio=`gawk -v y=$original -v x=$compressed 'BEGIN{printf "%.2f%%",x*100/y}'`;
     echo "$file the compress ratio is $ratio"
     mv -f tmp.gif $file

fi
done
