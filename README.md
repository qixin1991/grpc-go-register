# grpc-go-register

grpc golang server side register

# Usage Example

_server.go_

```go
package main

import (
	"flag"
	"fmt"
	"log"
	"net"
	"os"
	"os/signal"
	"syscall"
	"time"

	"golang.org/x/net/context"
	"google.golang.org/grpc"

	"github.com/qixin1991/grpc-go-register/rpc"

	"github.com/qixin1991/grpc-go-register/register"
)

var (
	serv = flag.String("service", "hello_service", "service name")
	port = flag.Int("port", 50001, "listening port")
	reg  = flag.String("reg", "http://172.20.9.101:2379,http://172.20.9.103:2379,http://172.20.9.105:2379", "register etcd address")
	host = flag.String("host", "", "local bind ip address")
)
var prefix = "etcd3_naming"

func main() {
	flag.Parse()

	if *host == "" {
		panic("Please Input Bind IP Address!")
	}
	lis, err := net.Listen("tcp", fmt.Sprintf("0.0.0.0:%d", *port))
	if err != nil {
		panic(err)
	}
	err = register.Registry(prefix, *serv, *host, *port, *reg, time.Second*10, 15)
	if err != nil {
		panic(err)
	}

	ch := make(chan os.Signal, 1)
	signal.Notify(ch, syscall.SIGTERM, syscall.SIGINT, syscall.SIGKILL, syscall.SIGHUP, syscall.SIGQUIT)
	go func() {
		s := <-ch
		log.Printf("receive signal '%v'", s)
		grpclb.UnRegister()
		os.Exit(0)
	}()

	log.Printf("starting hello service at %d", *port)
	s := grpc.NewServer()
	rpc.RegisterGreeterServer(s, &server{})
	s.Serve(lis)
}

// server is used to implement helloworld.GreeterServer.
type server struct{}

// SayHello implements helloworld.GreeterServer
func (s *server) SayHello(ctx context.Context, in *pb.HelloRequest) (*pb.HelloReply, error) {
	fmt.Printf("%v: Receive is %s\n", time.Now(), in.Name)
	return &pb.HelloReply{Message: "Hello " + in.Name}, nil
}

func (s *server) SayHelloAgain(ctx context.Context, in *pb.HelloRequest) (*pb.HelloReply, error) {
	fmt.Printf("%v: Receive Again is %s\n", time.Now(), in.Name)
	return &pb.HelloReply{Message: "Hello Again " + in.Name}, nil
}

```

Issue the following command

```shell
go run server.go --host [YOUR_IP] --reg [etcd3_cluster]
```