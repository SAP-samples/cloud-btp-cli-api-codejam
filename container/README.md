# Experimental container based working environment

As an alternative to using a Dev Space in the SAP Business Application Studio, we are experimenting with a container based approach to [your working environment](../exercises/01-installing/README.md#set-up-your-working-environment). This README will guide you through the steps you need to take to work through this CodeJam inside a container, instead of inside a Dev Space on App Studio.

These steps assume you have Docker Desktop installed (as described in the [Docker Desktop section of the Prerequisites document](../prerequisites.md#docker-desktop-optional)) and can execute the `docker` command on the command line. It also assumes you can execute the `git` command, to clone a repository. Don't worry if you don't have these tools or are not comfortable with these instructions, you can always just use a Dev Space which is the default for this CodeJam. If so, just head on back to the [Set up your working environment](../exercises/01-installing#set-up-your-working-environment) section of Exercise 01.

## Get the Dockerfile

You can download the [Dockerfile](Dockerfile) from this directory directly, or just clone the whole repository and then move into the repository locally:

```bash
git clone https://github.com/SAP-samples/cloud-btp-cli-api-codejam.git
cd cloud-btp-cli-api-codejam
```

## Examine the Dockerfile

If you look in the [Dockerfile](Dockerfile) you'll see that there are instructions for installing various command line tools including:

* the `cf` CLI for working with Cloud Foundry resources
* core tools such as `git` and `vim`
* the command line JSON processor `jq`
* a Node.js runtime

These are all tools that are also made available automatically in a basic Dev Space in App Studio (`cf` actually comes from the "MTA Tools" extension) - see [A basic Dev Space set up in the prerequisites](../prerequisites.md#a-basic-dev-space-set-up)). You'll also see that the executable that is invoked when a container is instantiated is `bash`, the Bash shell. This is the same shell that's also made available automatically for you in the terminals you invoke within a Dev Space in App Studio.

The reason for this is that it's important to make the image's environment as similar as possible to the environment in the Dev Space so folks can work in the same way and have a similar shared experience.

## Build the image

With the [Dockerfile](Dockerfile) in this directory, an image is built, and then you can instantiate a container from the image and work within that.

Move to the directory containing the `Dockerfile` file, and build the image like this:

```bash
cd container
docker build -t codejam .
```

You should see build output that looks something like this:

```text
[+] Building 0.1s (15/15) FINISHED
 => [internal] load build definition from Dockerfile                                                                                                           0.0s
 => => transferring dockerfile: 37B                                                                                                                            0.0s
 => [internal] load .dockerignore                                                                                                                              0.0s
 => => transferring context: 2B                                                                                                                                0.0s
 => [internal] load metadata for docker.io/library/debian:11                                                                                                   0.0s
 => [ 1/11] FROM docker.io/library/debian:11                                                                                                                   0.0s
 => CACHED [ 2/11] RUN apt-get update && apt-get install -y curl gpg lsb-release   && apt-get clean && rm -rf /var/lib/apt/lists/*   && curl -fsSL https://do  0.0s
 => CACHED [ 3/11] RUN curl -fsSL "https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key" | apt-key add -   && echo "deb https://packages.cloudfo  0.0s
 => CACHED [ 4/11] RUN apt-get update  && apt-get install -y     ca-certificates     cf7-cli     fzf     git     jq     shellcheck     vim-nox  && apt-get cl  0.0s
 => CACHED [ 5/11] WORKDIR /tmp/                                                                                                                               0.0s
 => CACHED [ 6/11] RUN curl -fsSL "https://deb.nodesource.com/setup_lts.x" | bash - && apt-get install -y nodejs                                               0.0s
 => CACHED [ 7/11] RUN curl -fsSL "https://github.com/mvdan/sh/releases/download/v3.4.1/shfmt_v3.4.1_linux_amd64" -o "/usr/local/bin/shfmt" && chmod +x "/usr  0.0s
 => CACHED [ 8/11] RUN rm -rf /tmp/*                                                                                                                           0.0s
 => CACHED [ 9/11] RUN adduser   --uid 1031   --quiet   --disabled-password   --shell /bin/bash   --home /home/user   --gecos "Dev User"   user  && chown use  0.0s
 => CACHED [10/11] WORKDIR /home/user                                                                                                                          0.0s
 => CACHED [11/11] RUN mkdir /home/user/projects                                                                                                               0.0s
 => exporting to image                                                                                                                                         0.0s
 => => exporting layers                                                                                                                                        0.0s
 => => writing image sha256:8b91a99b383b53a74b7a5797c0eb27db00e978fd0d6359274d16df409d051d8a                                                                   0.0s
 => => naming to docker.io/library/codejam                                                                                                                     0.0s
```

## Check the image

You can check the image was created successfully like this:

```bash
docker image ls codejam
```

You should see something similar to this:

```text
REPOSITORY   TAG       IMAGE ID       CREATED          SIZE
codejam      latest    48f9875c7529   2 minutes ago    541MB
```

You have an image and you're all set to create your first container from it.

## Create a container

Now create a container from the image. Do it like this:

```bash
docker run --interactive --tty --name my-codejam-container codejam
```

You'll be presented with a new prompt, which (if you've not worked inside containers before) may look slightly unfamiliar:

```text
user@807eeed3cdc6:~$
```

The Bash shell prompt shows that your username is `user` and that the hostname is a random string. You start in your home directory (`~`). You're not in Kansas any more, you're in a container!

## Re-connecting to your container

Now you're in your container, you can work happily away through the exercises.

If for whatever reason (perhaps you typed `exit` or used `Ctrl-D`) you find yourself back "outside", in your host environment, and you're wondering where everything went and how to get back in, you should know that because the container was instantiated without using the `--rm` option (which causes the container to be automatically removed when it exits), it is actually still hanging around.

If you were to run this command:

```bash
docker container ls
```

you wouldn't see it:

```text
CONTAINER ID   IMAGE          COMMAND                 CREATED          STATUS                     PORTS                                            NAMES
```

This is because without the use of the `--all` option, stopped containers are not shown. So re-run the command with this option:

```bash
docker container ls --all
```

and it will be there:

```text
CONTAINER ID   IMAGE          COMMAND                 CREATED          STATUS                     PORTS                                            NAMES
807eeed3cdc6   codejam        "bash"                  10 minutes ago   Exited (0) 3 minutes ago                                                    my-codejam-container
```

You must first restart the container:

```bash
docker start my-codejam-container
```

Then you can re-attach to it:

```bash
docker attach my-codejam-container
```

Any files you created should still be there, and you can continue.

## Cleaning up

At some point you may wish to clean up and remove your container. It might be because you've finished the CodeJam, or that you want to start over with a freshly instantiated container. 

You can remove your container by name. If it's still running and you still want to remove it, you must stop it first, like this:

```bash
docker container stop my-codejam-container
```

Then you can remove it:

```bash
docker container rm my-codejam-container
```

---

## A note on docker commands

In case you're wondering, the long, more explicit and modern form of the `docker` commands are used here. For example:

```bash
docker container ls --all
```

is used instead of

```bash
docker ps --all
```

In addition, options are expressed here mostly in their long form. For example:

```bash
docker run --interactive --tty --name my-codejam-container codejam
```

is used instead of

```bash
docker run -it --name my-codejam-container codejam
```

and 

```bash
docker container ls --all
```

is used instead of

```bash
docker container ls -a
```

This is simply to be more explicit as to what's going on. Feel free to use the shorter commands and options if you wish.
