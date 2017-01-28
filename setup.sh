#!/bin/bash

source certgen.sh

i=1

# selfsigned certificate
scenario="selfsigned"
dirname="s-$i-$scenario"
mkdir -p "$dirname"
name="localhost-selfsigned"
if [[ ! -d $name ]]; then
    x509KeyGen $name
    x509SelfSign --caTrue -t webserver $name
fi
cp $(x509Key $name) $dirname/
cp $(x509Cert $name) $dirname/
((i++))

#
scenario="ca-unknown"
dirname="s-$i-$scenario"
mkdir -p "$dirname"
name="ca-unknown"
if [[ ! -d $name ]]; then
    x509KeyGen $name
    x509SelfSign --DN 'CN=UnknownCA' $name
fi
name="localhost-unknown"
if [[ ! -d $name ]]; then
    x509KeyGen $name
    x509CertSign --CA ca-unknown $name
fi
cp $(x509Key $name) $dirname/
cp $(x509Cert $name) $dirname/
cp $(x509Cert ca-unknown) $dirname/ca.pem
((i++))

# will be needed in future
name="ca-trusted"
if [[ ! -d $name ]]; then
    x509KeyGen $name
    x509SelfSign --DN 'CN=DevConf2017CA' $name
fi

# server is signed by different ca than served
scenario="ca-mismatch"
dirname="s-$i-$scenario"
mkdir -p "$dirname"
cp $(x509Key localhost-unknown) $dirname/
cp $(x509Cert localhost-unknown) $dirname/
cp $(x509Cert ca-trusted) $dirname/ca.pem
((i++))

# server key does not match cert
scenario="key-mismatch"
dirname="s-$i-$scenario"
mkdir -p "$dirname"
cp $(x509Key localhost-unknown) $dirname/
cp $(x509Cert localhost-direct) $dirname/
cp $(x509Cert ca-trusted) $dirname/ca.pem
((i++))

#scenario="TODO"
#dirname="s-$i-$scenario"
#mkdir -p "$dirname"
#name="localhost-direct"
#if [[ ! -d $name ]]; then
#    x509KeyGen $name
#    x509CertSign --CA ca-trusted $name
#fi
#cp $(x509Key $name) $dirname/
#cp $(x509Cert $name) $dirname/
#((i++))

scenario="ca-intermediate-unknown"
dirname="s-$i-$scenario"
mkdir -p "$dirname"
name="ca-intermediate"
if [[ ! -d $name ]]; then
x509KeyGen $name
x509CertSign -t CA --CA ca-trusted $name
fi
name="localhost-intermediate"
if [[ ! -d $name ]]; then
    x509KeyGen $name
    x509CertSign --CA ca-intermediate $name
fi
cp $(x509Key $name) $dirname/
cp $(x509Cert $name) $dirname/
cp $(x509Cert ca-trusted) $dirname/ca.pem
((i++))

scenario="ca-intermediate"
dirname="s-$i-$scenario"
mkdir -p "$dirname"
cp $(x509Key $name) $dirname/
cp $(x509Cert $name) $dirname/
cat $(x509Cert ca-intermediate) $(x509Cert ca-trusted) >$dirname/ca.pem
((i++))

scenario="hostname"
dirname="s-$i-$scenario"
mkdir -p "$dirname"
name="localhost-badname"
if [[ ! -d $name ]]; then
    x509KeyGen $name
    x509CertSign --CA ca-trusted --DN 'CN=badname' $name
fi
cp $(x509Key $name) $dirname/
cp $(x509Cert $name) $dirname/
cp $(x509Cert ca-trusted) $dirname/ca.pem
((i++))

scenario="expired"
dirname="s-$i-$scenario"
mkdir -p "$dirname"
name="localhost-expired"
if [[ ! -d $name ]]; then
    x509KeyGen $name
    x509CertSign --CA ca-trusted --notBefore '3 years ago' --notAfter '2 years ago' $name
fi
cp $(x509Key $name) $dirname/
cp $(x509Cert $name) $dirname/
cp $(x509Cert ca-trusted) $dirname/ca.pem
((i++))

