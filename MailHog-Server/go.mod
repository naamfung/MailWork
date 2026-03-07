module github.com/naamfung/MailHog-Server

go 1.22.0

require (
	github.com/naamfung/data v0.0.0
	github.com/naamfung/smtp v0.0.0
	github.com/naamfung/storage v0.0.0
)

replace (
	github.com/naamfung/data => ../data
	github.com/naamfung/smtp => ../smtp
	github.com/naamfung/storage => ../storage
)