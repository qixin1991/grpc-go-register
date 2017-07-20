#!/bin/zsh
echo '---> 生成go代码...'
protoc -I rpc/ rpc/hw.proto --go_out=plugins=grpc:rpc
echo '---> ok.'