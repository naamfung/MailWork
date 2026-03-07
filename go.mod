module github.com/naamfung/MailHog

go 1.24.0

require (
	github.com/gorilla/pat v1.0.2
	github.com/ian-kent/envconf v0.0.0-20141026121121-c19809918c02
	github.com/ian-kent/go-log v0.0.0-20160113211217-5731446c36ab
	golang.org/x/crypto v0.48.0
)

require (
	github.com/naamfung/MailHog-Server v0.0.0
	github.com/naamfung/MailHog-UI v1.0.1
	github.com/naamfung/data v0.0.0
	github.com/naamfung/http v0.0.0
	github.com/naamfung/mhsendmail v0.0.0
	github.com/naamfung/smtp v0.0.0
	github.com/naamfung/storage v0.0.0
)

require (
	github.com/gorilla/context v1.1.2 // indirect
	github.com/gorilla/mux v1.8.1 // indirect
	github.com/gorilla/websocket v1.5.3 // indirect
	github.com/ian-kent/goose v0.0.0-20141221090059-c3541ea826ad // indirect
	github.com/ian-kent/linkio v0.0.0-20170807205755-97566b872887 // indirect
	github.com/mailhog/MailHog-UI v1.0.1 // indirect
	github.com/mailhog/data v1.0.1 // indirect
	github.com/philhofer/fwd v1.2.0 // indirect
	github.com/spf13/pflag v1.0.10 // indirect
	github.com/t-k/fluent-logger-golang v1.0.0 // indirect
	github.com/tinylib/msgp v1.6.3 // indirect
	gopkg.in/mgo.v2 v2.0.0-20190816093944-a6b53ec6cb22 // indirect
)

replace (
	github.com/naamfung/MailHog-Server => ./MailHog-Server
	github.com/naamfung/MailHog-UI => ./MailHog-UI
	github.com/naamfung/data => ./data
	github.com/naamfung/http => ./http
	github.com/naamfung/mhsendmail => ./mhsendmail
	github.com/naamfung/smtp => ./smtp
	github.com/naamfung/storage => ./storage
)
