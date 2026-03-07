package imap

import (
	"io"
	"log"
	"net"

	"github.com/naamfung/MailHog-Server/config"
)

func Listen(cfg *config.Config, exitCh chan int) *net.TCPListener {
	log.Printf("[IMAP] Binding to address: %s\n", cfg.IMAPBindAddr)
	ln, err := net.Listen("tcp", cfg.IMAPBindAddr)
	if err != nil {
		log.Fatalf("[IMAP] Error listening on socket: %s\n", err)
	}
	defer ln.Close()

	for {
		conn, err := ln.Accept()
		if err != nil {
			log.Printf("[IMAP] Error accepting connection: %s\n", err)
			continue
		}

		if cfg.Monkey != nil {
			ok := cfg.Monkey.Accept(conn)
			if !ok {
				conn.Close()
				continue
			}
		}

		go Accept(
			conn.(*net.TCPConn).RemoteAddr().String(),
			io.ReadWriteCloser(conn),
			cfg.Storage,
			cfg.Hostname,
			cfg.Monkey,
		)
	}
}
