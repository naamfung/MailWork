Building MailHog
================

MailHog can be built using the provided build scripts.

### Using build scripts

If you aren't making any code changes, you can build MailHog using the provided scripts:

- **Linux/macOS:**
  ```bash
  ./build.sh install
  ```
- **Windows:**
  ```cmd
  build.bat
  ```

This will generate an executable named `mailhog` (or `mailhog.exe` on Windows) in the current directory.

### Using the comprehensive build script

For more control over the build process, you can use the comprehensive build script:

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

### Why do I need build scripts?

MailHog has HTML, CSS and Javascript assets which need to be converted
to a go source file using [go-bindata](https://github.com/jteeuwen/go-bindata).

This must happen before running `go build` or `go install` to avoid compilation
errors (e.g., `no buildable Go source files in MailHog-UI/assets`).

### go generate

The build should be updated to use `go generate` (added in Go 1.4) to
preprocess static assets into go source files.

However, this will break backwards compatibility with Go 1.2/1.3.

### Building a release

Releases are built using [gox](https://github.com/mitchellh/gox).

Run `make release` to cross-compile for all available platforms.
