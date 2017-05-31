#!/bin/bash
#Mass SSL v1.0

#timeout () { perl -e 'alarm shift; exec @ARGV' "$@"; } # define a helper function

# -tls1 -ssl3
# Check tls1

echo -e "\n massSSL v1.0 \n\n"

version=$(echo "version" | openssl | cut -f3 -d " ")
echo -e "OpennSSL version: $version \n"

#if [ ${#} -eq 0 ]
if [ $@ != 1 ]; then

  echo -e "\n ./massSSL.sh tagets.txt"

else
  if [ $1 == '--install' ]; then
    echo "Installing dependencies..."
    wget https://www.openssl.org/source/openssl-0.9.8k.tar.gz
    tar -xvzf openssl-0.9.8k.tar.gz
    mv openssl-0.9.8k ./lib/
    cd ./lib
    ./Configure darwin64-x86_64-cc -shared --openssldir="/tools/massSSL"
    make
    cd ./../
    rm -f openssl-0.9.8k.tar.gz
  #else
  #  echo -e "Ooops! Option $1 was not recognised \n"
  #  exit
  fi
fi

for ip in $(cat $1);
do

# Supress Bash Errors
exec 3>&2
exec 2> /dev/null


ciphers=$(openssl ciphers 'ALL:eNULL' | sed -e 's/:/ /g')

output=$((echo " " | /usr/bin/openssl s_client -connect $ip:443 -cipher "DES-CBC3-SHA" )& sleep 5;pkill -f "openssl")

  if (echo $output | grep -q "END CERTIFICATE"); then
    echo $ip >> DES_CBC3_SHA_ciphers.txt
    echo "[+] $ip : DES-CBC3-SHA is supported"
  else
    echo "[-] $ip : DES-CBC3-SHA NOT supported"
  fi

  if (echo $output | grep -q "self signed"); then
    echo $ip >> certificates.txt
    echo "[+] $ip : Self Signed Certificate Detected"
  fi

output=$((echo " \n" | /usr/bin/openssl s_client -connect $ip:443 -ssl3 -cipher "RC4")& sleep 5;pkill -f "openssl")

  if (echo $output | grep -q "END CERTIFICATE"); then
    echo $ip >> rc4.txt
    echo "[+] $ip : RC4 is supported"
  else
    echo "[-] $ip : RC4 NOT supported"
  fi

output=$((echo "" | /usr/bin/openssl s_client -connect $ip:443 -ssl3 -cipher "EXP")& sleep 5;pkill -f "openssl")

    if (echo $output | grep -q "END CERTIFICATE"); then
      echo $ip >> exp.txt
      echo "[+] $ip : EXP is supported"
    else
      echo "[-] $ip : EXP NOT supported"
    fi
done;
