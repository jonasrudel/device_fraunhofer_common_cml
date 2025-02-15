#!/bin/bash

set -e

# Create test-quote
TESTQUOTE_LEN=$(($RANDOM % 1024))

echo "TESTQUOTE_LEN=${TESTQUOTE_LEN}"

dd if=/dev/random of=test-quote bs=1 count=${TESTQUOTE_LEN}
rm -f test-quote
touch test-quote

# Create test-quote digests
echo "Generating hashes"
openssl dgst -sha256 -binary test-quote > test-quote-hash
openssl dgst -sha512 -binary test-quote > test-quote-hash_sha512

# Create RSA-SSA signatures
echo "Generating RSA-SSA signatures"
openssl dgst -sha256 -sign testpki/ssig.key -out sigssa_ssacert test-quote
openssl dgst -sha256 -sign testpki/ssig_cml.key -out sigssa_psscert test-quote

openssl dgst -sha512 -sign testpki/ssig.key -out sigssa_ssacert_sha512 test-quote
openssl dgst -sha512 -sign testpki/ssig_cml.key -out sigssa_psscert_sha512 test-quote

# Create RSA-PSS signature
echo "Generating RSA-PSS signatures"
openssl dgst -sha256 -sign testpki/ssig_cml.key -out sigpss_psscert -sigopt rsa_padding_mode:pss -sigopt rsa_pss_saltlen:-1 test-quote
openssl dgst -sha256 -sign testpki/ssig.key -out sigpss_ssacert -sigopt rsa_padding_mode:pss -sigopt rsa_pss_saltlen:-1 test-quote

openssl dgst -sha512 -sign testpki/ssig_cml.key -out sigpss_psscert_sha512 -sigopt rsa_padding_mode:pss -sigopt rsa_pss_saltlen:-1 test-quote
openssl dgst -sha512 -sign testpki/ssig.key -out sigpss_ssacert_sha512 -sigopt rsa_padding_mode:pss -sigopt rsa_pss_saltlen:-1 test-quote

# Create PKCS12 tokens
echo "Generating PKCS12 tokens"
openssl pkcs12 -export -out token.p12 -inkey testpki/ssig.key -in testpki/ssig.cert -password pass:trustme
openssl pkcs12 -export -out token_pss.p12 -inkey testpki/ssig_cml.key -in testpki/ssig_cml.cert -password pass:trustme
