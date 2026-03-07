package imap

import (
	"fmt"
	"io"
	"log"
	"strings"

	"github.com/ian-kent/linkio"
	"github.com/naamfung/MailHog-Server/monkey"
	"github.com/naamfung/storage"
)

// Session represents an IMAP session using net.TCPConn
type Session struct {
	conn          io.ReadWriteCloser
	storage       storage.Storage
	remoteAddress string
	line          string
	link          *linkio.Link

	reader io.Reader
	writer io.Writer
	monkey monkey.ChaosMonkey

	// IMAP session state
	authenticated   bool
	selectedMailbox string
}

// Accept starts a new IMAP session using io.ReadWriteCloser
func Accept(remoteAddress string, conn io.ReadWriteCloser, storage storage.Storage, hostname string, monkey monkey.ChaosMonkey) {
	defer conn.Close()

	var link *linkio.Link
	reader := io.Reader(conn)
	writer := io.Writer(conn)
	if monkey != nil {
		linkSpeed := monkey.LinkSpeed()
		if linkSpeed != nil {
			link = linkio.NewLink(*linkSpeed * linkio.BytePerSecond)
			reader = link.NewLinkReader(io.Reader(conn))
			writer = link.NewLinkWriter(io.Writer(conn))
		}
	}

	session := &Session{conn, storage, remoteAddress, "", link, reader, writer, monkey, false, ""}

	session.logf("Starting session")
	session.Write("* OK [%s] MailHog IMAP4rev1 Service Ready\r\n", hostname)
	for session.Read() == true {
		if monkey != nil && monkey.Disconnect != nil && monkey.Disconnect() {
			session.conn.Close()
			break
		}
	}
	session.logf("Session ended")
}

func (c *Session) logf(message string, args ...interface{}) {
	message = strings.Join([]string{"[IMAP %s]", message}, " ")
	args = append([]interface{}{c.remoteAddress}, args...)
	log.Printf(message, args...)
}

// Read reads from the underlying net.TCPConn
func (c *Session) Read() bool {
	buf := make([]byte, 1024)
	n, err := c.reader.Read(buf)

	if n == 0 {
		c.logf("Connection closed by remote host\n")
		io.Closer(c.conn).Close() // not sure this is necessary?
		return false
	}

	if err != nil {
		c.logf("Error reading from socket: %s\n", err)
		return false
	}

	text := string(buf[0:n])
	logText := strings.Replace(text, "\n", "\\n", -1)
	logText = strings.Replace(logText, "\r", "\\r", -1)
	c.logf("Received %d bytes: '%s'\n", n, logText)

	c.line += text

	for strings.Contains(c.line, "\r\n") {
		remaining, currentLine := c.parseLine(c.line)
		c.line = remaining

		c.ProcessCommand(currentLine)
	}

	return true
}

// Write writes a reply to the underlying net.TCPConn
func (c *Session) Write(format string, args ...interface{}) {
	reply := fmt.Sprintf(format, args...)
	logText := strings.Replace(reply, "\n", "\\n", -1)
	logText = strings.Replace(logText, "\r", "\\r", -1)
	c.logf("Sent %d bytes: '%s'", len(reply), logText)
	c.writer.Write([]byte(reply))
}

// parseLine parses a line string and returns any remaining line string
func (c *Session) parseLine(line string) (string, string) {
	parts := strings.SplitN(line, "\r\n", 2)
	if len(parts) == 2 {
		return parts[1], parts[0]
	}
	return "", line
}

// ProcessCommand processes an IMAP command
func (c *Session) ProcessCommand(line string) {
	// Parse the command
	parts := strings.SplitN(line, " ", 2)
	if len(parts) < 2 {
		c.Write("* BAD Invalid command\r\n")
		return
	}

	tag := parts[0]
	cmdParts := strings.SplitN(parts[1], " ", 2)
	command := strings.ToUpper(cmdParts[0])
	args := ""
	if len(cmdParts) > 1 {
		args = cmdParts[1]
	}

	// Process the command
	switch command {
	case "CAPABILITY":
		c.handleCapability(tag)
	case "LOGIN":
		c.handleLogin(tag, args)
	case "SELECT":
		c.handleSelect(tag, args)
	case "FETCH":
		c.handleFetch(tag, args)
	case "SEARCH":
		c.handleSearch(tag, args)
	case "LOGOUT":
		c.handleLogout(tag)
	default:
		c.Write("%s BAD Unknown command\r\n", tag)
	}
}

// handleCapability handles the CAPABILITY command
func (c *Session) handleCapability(tag string) {
	c.Write("* CAPABILITY IMAP4rev1 AUTH=PLAIN\r\n")
	c.Write("%s OK CAPABILITY completed\r\n", tag)
}

// handleLogin handles the LOGIN command
func (c *Session) handleLogin(tag string, args string) {
	// Parse username and password
	// Handle quoted parameters
	
	// Find first quote
	firstQuote := strings.Index(args, "\"")
	if firstQuote == -1 {
		c.Write("%s BAD Invalid login parameters\r\n", tag)
		return
	}
	
	// Find second quote
	secondQuote := strings.Index(args[firstQuote+1:], "\"")
	if secondQuote == -1 {
		c.Write("%s BAD Invalid login parameters\r\n", tag)
		return
	}
	secondQuote += firstQuote + 1
	
	// Find third quote
	thirdQuote := strings.Index(args[secondQuote+1:], "\"")
	if thirdQuote == -1 {
		c.Write("%s BAD Invalid login parameters\r\n", tag)
		return
	}
	thirdQuote += secondQuote + 1
	
	// Find fourth quote
	fourthQuote := strings.Index(args[thirdQuote+1:], "\"")
	if fourthQuote == -1 {
		c.Write("%s BAD Invalid login parameters\r\n", tag)
		return
	}

	// MailHog doesn't validate credentials
	c.authenticated = true
	c.Write("%s OK LOGIN completed\r\n", tag)
}

// handleSelect handles the SELECT command
func (c *Session) handleSelect(tag string, args string) {
	if !c.authenticated {
		c.Write("%s NO Login required\r\n", tag)
		return
	}

	// Parse mailbox name
	mailbox := strings.TrimSpace(args)
	if mailbox == "" {
		mailbox = "INBOX"
	}

	c.selectedMailbox = mailbox
	c.Write("* 0 EXISTS\r\n")
	c.Write("* 0 RECENT\r\n")
	c.Write("* FLAGS (\\Answered \\Flagged \\Deleted \\Seen \\Draft)\r\n")
	c.Write("* OK [UNSEEN 0]\r\n")
	c.Write("* OK [UIDVALIDITY 1]\r\n")
	c.Write("* OK [UIDNEXT 1]\r\n")
	c.Write("%s OK SELECT completed\r\n", tag)
}

// handleFetch handles the FETCH command
func (c *Session) handleFetch(tag string, args string) {
	if !c.authenticated {
		c.Write("%s NO Login required\r\n", tag)
		return
	}

	if c.selectedMailbox == "" {
		c.Write("%s NO No mailbox selected\r\n", tag)
		return
	}

	// For now, return empty result
	c.Write("%s OK FETCH completed\r\n", tag)
}

// handleSearch handles the SEARCH command
func (c *Session) handleSearch(tag string, args string) {
	if !c.authenticated {
		c.Write("%s NO Login required\r\n", tag)
		return
	}

	if c.selectedMailbox == "" {
		c.Write("%s NO No mailbox selected\r\n", tag)
		return
	}

	// For now, return empty result
	c.Write("* SEARCH\r\n")
	c.Write("%s OK SEARCH completed\r\n", tag)
}

// handleLogout handles the LOGOUT command
func (c *Session) handleLogout(tag string) {
	c.Write("* BYE MailHog IMAP4rev1 Service closing connection\r\n")
	c.Write("%s OK LOGOUT completed\r\n", tag)
	c.conn.Close()
}
