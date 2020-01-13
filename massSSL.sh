#!/bin/bash
#Mass SSL v1.1

# -tls1 -ssl3
# Check tls1

echo -e "\n massSSL v1.0 \n\n"
echo -e "Author: superhedgy"

version=$(echo "version" | openssl | cut -f3 -d " ")

if [  "$(which openssl)" != "" ]; then
  echo -e "OpenSSL version: $version \n"
else
  echo -e "OpenSSL was not detected. Please use the --install option ./massSSL.sh --install"
  exit 1
fi

#if [ ${#} -eq 0 ]
if [ $# -lt 1 ]; then
  echo -e "Usage: ./massSSL.sh targets.txt [--install] [--port <PORT>]\n"
  exit 1
fi 

port=443

infile=$1

while [ -n "$1" ];
do
  case "$1" in
    --install)
      echo "Installing dependencies..."
      wget https://www.openssl.org/source/openssl-0.9.8k.tar.gz
      tar -xvzf openssl-0.9.8k.tar.gz
      mv openssl-0.9.8k ./lib/
      cd ./lib
      ./Configure darwin64-x86_64-cc -shared
      make
      cd ./../
      rm -f openssl-0.9.8k.tar.gz
      ;;
    --port)
      echo -e "Using port: $2\n"
      port=$2
      ;;
    *)
      ;;
  esac
  shift
done

echo -e "file is $infile"

for ip in $(cat $infile);
do

# Supress Bash Errors
exec 3>&2
exec 2> /dev/null

ciphers=$(openssl ciphers 'ALL:eNULL' | sed -e 's/:/ /g')

ssl2=$(echo " \n\n" | /usr/bin/openssl s_client -connect $ip:$port -ssl2&)
ssl3=$(echo " \n\n" | /usr/bin/openssl s_client -connect $ip:$port -ssl3&)
tls1=$(echo " \n\n" | /usr/bin/openssl s_client -connect $ip:$port -tls1&)
cipher1=$(echo " \n\n" | /usr/bin/openssl s_client -connect $ip:$port -cipher "DES-CBC3-SHA"&)
cipher2=$(echo " \n\n" | /usr/bin/openssl s_client -connect $ip:$port -ssl3 -cipher "RC4"&)
cipher3=$(echo " \n\n" | /usr/bin/openssl s_client -connect $ip:$port -ssl3 -cipher "EXP"&)

wait
echo -e "$ip:"
  if (echo $ssl2 | grep -q "END CERTIFICATE"); then
    echo $ip >> ssl2.txt
    echo -e "[+] SSL v2.0 protocol \e[31mis supported\e[0m"
  else
    echo -e "[-] SSL v2.0 protocol \e[32mis NOT supported\e[0m"
  fi

  if (echo $ssl3 | grep -q "END CERTIFICATE"); then
    echo $ip >> ssl3.txt
    echo -e "[+] SSL v3.0 protocol \e[31mis supported\e[0m"
  else
    echo -e "[-] SSL v3.0 protocol \e[32mis NOT supported\e[0m"
  fi

  if (echo $tls1 | grep -q "END CERTIFICATE"); then
    echo $ip >> tls1.txt
    echo -e "[+] TLS v1.0 protocol \e[31mis supported\e[0m"
  else
    echo -e "[-] TLS v1.0 protocol \e[32mis NOT supported\e[0m"
  fi

  if (echo $cipher1 | grep -q "END CERTIFICATE"); then
    echo $ip >> DES_CBC3_SHA_ciphers.txt
    echo -e "[+] DES-CBC3-SHA \e[31mis supported\e[0m"
  else
    echo -e "[-] DES-CBC3-SHA \e[32mis NOT supported\e[0m"
  fi

  if (echo $cipher2 | grep -q "END CERTIFICATE"); then
    echo $ip >> rc4.txt
    echo -e "[+] RC4 \e[31mis supported\e[0m"
  else
    echo -e "[-] RC4 \e[32mis NOT supported\e[0m"
  fi

  if (echo $cipher3 | grep -q "END CERTIFICATE"); then
      echo $ip >> exp.txt
      echo -e "[+] EXP \e[31mis supported\e[0m"
  else
      echo -e "[-] EXP \e[32mis NOT supported\e[0m"
  fi

  if (echo $cipher1 | grep -q "self signed"); then
    echo $ip >> certificates.txt
    echo -e "[+] \e[31mSelf Signed Certificate Detected\e[0m"
  fi

done;
