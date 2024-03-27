# Build scripts

**DISCLAIMER**: This is only for Debian-based distributions. WSL is **NOT** supported.

## Prerequisites

1. (Optional) Make a Telegram Bot ([@BotFather](https://t.me/BotFather)).

2. Fork this repository.

3. Make a GitHub token with proper permissions for uploading releases to your repositories.

## How to use this repo (non-Jenkins)

1. Clone your fork of this repository.

2. Make your changes in `config.sh` (more information about the flags below). Make sure you commit and push your changes to your fork.

3. Export GITHUB_TOKEN to your GitHub token (make sure it has permissions to upload releases to your repos).

4. Optionally export TELEGRAM_CHAT and TELEGRAM_TOKEN to your respective values:

* `TELEGRAM_CHAT` - the ID of the channel/group chat you want the Bot to post your messages to.

* `TELEGRAM_TOKEN` - the token of your Telegram Bot.

5. If you haven't ever built Android on your PC, have a look [here](https://source.android.com/docs/setup/start/initializing) on how to setup your PC for Android building.

6. Then run `init.sh` from the same folder.

OR

5. If you've already built Android on your PC, run `init.sh`.

## How to use this repo (Jenkins)

1. Clone your fork of this repository.

2. Make your changes in `config.sh` (more information about the flags below). Make sure you commit and push your changes to your fork.

3. Open the Jenkins web console.

4. Make a new job with the "Freeflow" type. Do **NOT** put spaces in the name of the job.

5. Add a build step for bash.

6. Copy the contents of `jenkins.sh` to it.

7. Change the values of GITHUB_TOKEN and optionally TELEGRAM_CHAT, TELEGRAM_TOKEN to your respective values:

* `GITHUB_TOKEN` - your GitHub token (make sure it has permissions to upload releases to your repos).

* `TELEGRAM_CHAT` - the ID of the channel/group chat you want the Bot to post your messages to.

* `TELEGRAM_TOKEN` - the token of your Telegram Bot.

8. Edit the `git clone` command for your fork.

## Configuration flags

`GITHUB_USER` - your GitHub username

`GITHUB_EMAIL` - your GitHub email

`jenkins` - `true` - you use Jenkins; `false` - you don't use Jenkins

`release_repo` - your GitHub username + name of the repo to upload the releases (e.g. `JarlPenguin/releases`)

`timezone` - your timezone (default: `UTC`)
