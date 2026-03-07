MailHog [ ![Download](https://img.shields.io/github/release/mailhog/MailHog.svg) ](https://github.com/mailhog/MailHog/releases/tag/v1.0.0) [![GoDoc](https://godoc.org/github.com/naamfung/MailHog?status.svg)](https://godoc.org/github.com/naamfung/MailHog)
=========

Inspired by [MailCatcher](https://mailcatcher.me/), easier to install.

* Download and run MailHog
* Configure your outgoing SMTP server
* View your outgoing email in a web UI
* Release it to a real mail server

Built with Go - MailHog runs without installation on multiple platforms.

### Overview

MailHog is an email testing tool for developers:

* Configure your application to use MailHog for SMTP delivery
* View messages in the web UI, or retrieve them with the JSON API
* Optionally release messages to real SMTP servers for delivery

### Installation

#### From source

1. Clone the repository:
   ```bash
   git clone https://github.com/naamfung/MailHog.git
   cd MailHog
   ```

2. Build and install using the provided scripts:
   - **Linux/macOS:**
     ```bash
     ./install.sh
     ```
   - **Windows:**
     ```cmd
     install.bat
     ```

3. Start MailHog by running `mailhog` in the command line.

#### Manual build

You can also build the project manually:

- **Linux/macOS:**
  ```bash
  ./build.sh
  ```
- **Windows:**
  ```cmd
  build.bat
  ```

This will generate an executable named `mailhog` (or `mailhog.exe` on Windows) in the current directory.

#### Docker

You can build and run MailHog using the provided Dockerfile and build script:

```bash
# 构建并运行 Docker 容器
./docker-build-deploy.sh --build --run

# 后台运行容器
./docker-build-deploy.sh --build --run --detach

# 使用 Maildir 存储运行容器
./docker-build-deploy.sh --build --run --storage maildir

# 停止并移除容器
./docker-build-deploy.sh --stop
```

For more options, run `./docker-build-deploy.sh --help`

### Configuration

Check out how to [configure MailHog](/docs/CONFIG.md), or use the default settings:
  * the SMTP server starts on port 1025
  * the IMAP server starts on port 143
  * the HTTP server starts on port 8025
  * in-memory message storage

### Features

See [MailHog libraries](docs/LIBRARIES.md) for a list of MailHog client libraries.

* ESMTP server implementing RFC5321
* IMAP server implementing IMAP4rev1
* Support for SMTP AUTH (RFC4954) and PIPELINING (RFC2920)
* Web interface to view messages (plain text, HTML or source)
  * Supports RFC2047 encoded headers
* Real-time updates using EventSource
* Release messages to real SMTP servers
* Chaos Monkey for failure testing
  * See [Introduction to Jim](/docs/JIM.md) for more information
* HTTP API to list, retrieve and delete messages
  * See [APIv1](/docs/APIv1.md) and [APIv2](/docs/APIv2.md) documentation for more information
* [HTTP basic authentication](docs/Auth.md) for MailHog UI and API
* Multipart MIME support
* Download individual MIME parts
* In-memory message storage
* MongoDB and file based storage for message persistence
* Lightweight and portable
* No installation required

#### sendmail

[mhsendmail](https://github.com/naamfung/mhsendmail) is a sendmail replacement for MailHog.

It redirects mail to MailHog using SMTP.

You can also use `mailhog sendmail ...` instead of the separate mhsendmail binary.

Alternatively, you can use your native `sendmail` command by providing `-S`, for example:

```bash
/usr/sbin/sendmail -S mail:1025
```

For example, in PHP you could add either of these lines to `php.ini`:

```
sendmail_path = /usr/local/bin/mhsendmail
sendmail_path = /usr/sbin/sendmail -S mail:1025
```

#### Web UI

![Screenshot of MailHog web interface](/docs/MailHog.png "MailHog web interface")

### Contributing

MailHog is a rewritten version of [MailHog](https://github.com/ian-kent/MailHog), which was born out of [M3MTA](https://github.com/ian-kent/M3MTA).

Clone this repository to ```$GOPATH/src/github.com/naamfung/MailHog``` and run the build script:

```bash
# 格式化代码
./build.sh fmt

# 安装项目
./build.sh install

# 格式化代码并安装项目
./build.sh all

# 构建跨平台发布版本
./build.sh release
```

See the [Building MailHog](/docs/BUILD.md) guide.

Requires Go 1.22+ to build.

Run tests using ```go test ./...``` or ```goconvey```.

If you make any changes, run ```./build.sh fmt``` before submitting a pull request.

### Licence

Copyright ©‎ 2014 - 2017, Ian Kent (http://iankent.uk)
Copyright ©‎ 2026, naamfung

Released under MIT license, see [LICENSE](LICENSE.md) for details.
