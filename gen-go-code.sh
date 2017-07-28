#!/bin/zsh
echo '---> code genertor for Go...'
protoc -I rpc/ rpc/hw.proto --go_out=plugins=grpc:rpc
echo '---> ok.'