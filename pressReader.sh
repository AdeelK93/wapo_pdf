#!/bin/bash
cd "$(dirname "$0")"

if [ ! -f "cookiex" ]; then
  echo "cookie file does not exist"
  echo "You can find your Washington Post cookie (requires subscribership) by visiting:"
  echo "https://thewashingtonpost.pressreader.com/the-washington-post/"
  echo "After signing in, open up the developer tools console of your browser"
  echo "Type in: document.cookie"
  echo "Place the response (without quotes) into the cookie file you create (no extension)"
  exit
fi

if [[ `date +%u` -eq 7 ]]; then
  echo "Sunday edition"
  mainurl='https://thewashingtonpost.pressreader.com/the-washington-post-sunday/'
  cid="1058"
else
  mainurl='https://thewashingtonpost.pressreader.com/the-washington-post/'
  cid="1047"
fi
issue="${cid}`date +%Y%m%d`"

main=$(curl --location $mainurl -s --header "Cookie: `cat cookie`")

token=`echo $main | perl -ne 'print "$1" if /accessToken":"(.*?)"/'`
echo $token

keys=`curl --location "https://svc.pressreader.com/se2skyservices/IssueInfo/GetPageKeys/?accessToken=${token}&issue=${issue}00000000001001&pageNumber=0" -s`

pageKeys=`echo $keys | sed 's/}/}\n/g' | perl -ne 'print "$1 " if /Key":"(.*?)"/'`
keyArray=(${pageKeys})

# https://svc.pressreader.com/se2skyservices/IssueInfo/GetIssueInfoByCid/?accessToken=${token}!!&cid=${cid}
# hardcoding these magnifier values
magW=1728
magH=3024
scales=`curl -s  "https://s.prcdn.co/se2skyservices/toc/?callback=tocCallback&issue=${issue}00000000001001&version=3&expungeVersion=" | ./scales.R $magW $magH`
scaleArray=($(echo $scales | cut -f1 -d ';'))
lengthArray=($(echo $scales | cut -f2 -d ';'))

rm *.png
for ((idx=0; idx<${#keyArray[@]}; ++idx)); do
  page=$((idx + 1))
  echo -ne "Page $page\r"
  if [[ ${lengthArray[idx]} -ne 0 ]]; then
    wget -q -O "p${page}.png" "https://i.prcdn.co/img?file=${issue}00000000001001&page=${page}&scale=${scaleArray[idx]}&ticket=${keyArray[idx]}"
  fi
done

echo -ne 'Done downloading\n'

uuid=$(cat /proc/sys/kernel/random/uuid)

rm -rf ZipDocument/*
mkdir ZipDocument/$uuid.thumbnails
img2pdf `ls -1v *.png` --output ZipDocument/$uuid.pdf -s x1872 &
mogrify -background white -gravity center -resize 280x374\> -extent 280x374 -format jpg *.png &
echo "{\"extraMetadata\": {}, \"lastOpenedPage\": 0, \"lineHeight\": -1, \"margins\": 180, \"pageCount\": `ls *.png | wc -l`, \"textScale\": 1, \"transform\": {}, \"fileType\": \"pdf\"}" > ZipDocument/$uuid.content
wait
thumbnails=(`ls -1v *.jpg`)
for ((idx=0; idx<${#thumbnails[@]}; ++idx)); do
  # dense rank
  mv ${thumbnails[idx]} ZipDocument/$uuid.thumbnails/$idx.jpg
done

cd ZipDocument
zip -r wapo.zip *
mv wapo.zip ../
cd ..

echo "Done converting"

./transfer.py
echo "Transfer complete"