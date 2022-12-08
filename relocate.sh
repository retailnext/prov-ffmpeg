
#!/bin/bash -e

for F in $1/*.pc; do
  old_path=$( sed -n /^prefix=/p $F | sed s/prefix=// )
  sed -i.sav -e "s;$old_path;$2;g" $F
  rm -f $F.sav
done
