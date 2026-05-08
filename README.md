# Deploy an OpenFang on Pergola

[Pergola](https://docs.pergola.cloud/docs/overview) is a deployment and runtime platform for web and server applications, a high-availability cluster with auto-scaling, failover handling, fully managed TLS certificates and much more.

[OpenFang](https://github.com/RightNow-AI/openfang) is an open-source Agent Operating System built in Rust, designed to run persistent, autonomous AI agents that operate continuously on schedules rather than waiting for user prompts. Unlike traditional chatbot frameworks, it provides a secure runtime with features like sandboxed execution, persistent memory, and pre-built "Hands" for tasks such as monitoring, workflow automation, and reporting.

You can deploy your personal isolated OpenFang instance on Pergola in a matter of minutes, just follow the steps below.

---
## Deployment Steps

If you do not have a Pergola account yet, signup here: https://console.pergola.cloud

You can use the [CLI](https://get.pergo.la/cli) as described below, or follow the same steps in the [web UI](https://console.pergola.cloud).

### 1. Create your Project

```sh
# Generate a unique project ID
PROJECT_ID="my-openfang-$(openssl rand -hex 2)"

pergola create project $PROJECT_ID \
  --git-url https://github.com/datasophie/openfang-pergola.git \
  --display-name "My OpenFang"
```

---
### 2. Push Build
Push the build, it will run in the background:
```sh
pergola push build -p $PROJECT_ID
```
This may take a few minutes, but you can proceed with the next steps.

---
### 3. Create a Stage
This will be your personal OpenFang environment:
```sh
pergola create stage dev -p $PROJECT_ID --type dev
```
You can create as many Stages as you wish.

---
### 3. Set environment variable `OPENFANG_API_KEY`
This api key is required in order to authenticate with OpenFang (i.e. when accessing its Dashboard or API).
Generate a random secret and bind it to your Stage:
```sh
# Generate a random API key
OPENFANG_API_KEY=$(openssl rand -hex 32)

# Bind the API key to the stage
pergola add config-data default -p $PROJECT_ID -s dev \
  --env OPENFANG_API_KEY=$OPENFANG_API_KEY
  
# Show the API key
echo "your OPENFANG_API_KEY: $OPENFANG_API_KEY"
# or retrieve it anytime from Pergola
pergola list config-data -p $PROJECT_ID -s dev default --with-values
```

---
### 4. Push Release once Build is ready
```sh
# Check if your build is ready
pergola list builds -p $PROJECT_ID

# Once ready, push a new release with the latest build and your configuration
pergola push release -p $PROJECT_ID -s dev -b main_b1 -c default

# Get URL of the just deployed OpenFang Dashboard
pergola list components -p $PROJECT_ID -s dev
```

👍 The part on Pergola is done. Now you can finish the setup of OpenFang itself.

---
### 5. Initialize OpenFang
Run OpenFang's initializer once after the first release:
```sh
pergola exec openfang -p $PROJECT_ID -s dev -- openfang init
```

This creates `/data/config.toml` and the OpenFang home layout on the storage. The file is owned by OpenFang, you can edit it with OpenFang CLI commands, from inside the container, or through the OpenFang dashboard.

🚀 **That's it! Your OpenFang is live at the URL Pergola has provided above.**

---
## Operate

You can launch the OpenFang CLI via:
```sh
pergola exec openfang -p $PROJECT_ID -s dev -- openfang
```

or `bash` into your environment then run the commands you need:
```sh
pergola exec openfang -p $PROJECT_ID -s dev -- bash
```

For convenience, you can add this alias to your shell config:
```sh
alias openfang="pergola exec openfang -p $PROJECT_ID -s dev -- openfang"
```

Then just run `openfang status` or `openfang agent list` etc.
See [OpenFang documentation](https://www.openfang.sh/docs/cli-reference#command-reference) for further CLI options and details.

**Any command you run is executed seamlessly *inside* the Stage, not on your local machine.**

---

### Configuration options

After a fresh release to a new Stage, you should run:
```sh
openfang init
```

For editing the OpenFang configuration:
```sh
openfang config
```

`OPENFANG_HOME` is `/data`, where OpenFang stores its configuration, i.e. `config.toml`, SQLite data, daemon metadata, and agent state. This is mapped to a persistent storage in the [pergola.yaml](pergola.yaml) so data is not lost after a restart.

Following configuration data can be managed on Pergola:

| Key | Description | Default |
|---|---|---|
| `OPENFANG_API_KEY` | Authenticates requests to the dashboard and API | *(none)* must be set before first Release
| `.env` file | OpenFang environment variables, see [.env.example](https://raw.githubusercontent.com/RightNow-AI/openfang/refs/heads/main/.env.example) for available configuration options | empty, no extra settings |
| `EDITOR` | The editor to use for `openfang config edit`; `nano` and `vim` are pre-installed | `nano` |
| `RUST_LOG` | Log level (e.g. `info`, `debug`) - bump to `debug` when troubleshooting | `info` |

Re-release (with same Build) after changing any of the configuration data keys above. See [Pergola Stage Configuration](https://docs.pergola.cloud/docs/reference/configurations) for further details.

---
### Runtime dependencies

OpenFang-Hands may shell out to system binaries. Install required dependencies in
the running container when a specific Hand/tool needs them:

```sh
pergola exec openfang -p $PROJECT_ID -s dev -- \
  bash -lc 'apt-get install <the_required_packages>'
```

The container filesystem is ephemeral - every restart wipes manual installs or changes outside `/data`. For persistent dependencies or further customisations, fork this repository and point your [Pergola Project](https://docs.pergola.cloud/docs/reference/projects) to your new repository.

## Contributing

Pull requests are always welcome! Thank you.
