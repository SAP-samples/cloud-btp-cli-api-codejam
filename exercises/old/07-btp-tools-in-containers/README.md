# Exercise 07 - BTP tools in containers

At the end of this exercise, you'll have an appreciation for the utility of containers when working on the command line. More specifically, you'll understand how containers can be a powerful meta-tool, especially when the container image already contains curated BTP tools for you.

## Working on the command line

If you've got this far in this hands-on session, you will have gained some insight into how powerful the command line can be. This is true for all command lines, but perhaps "more true" in those command line contexts that are based upon the [Unix Philosophy](https://en.wikipedia.org/wiki/Unix_philosophy), with tools that can be combined in pipelines, and a command line environment that is the same as the scripting language used to create your own utilities and tools.

In order for all the participants to have the same experience during this hands-on session, we opted to use the SAP Business Application Studio (App Studio), being an environment that supports a terminal, running a Bash shell, out of the box, in all Dev Space types. This is a great start, but you may want to have more flexibility, or be able to conjure up a shell to work within, wherever you happen to be. Working on the command line needn't be constrained to how your actual laptop or desktop machine is set up, or what operating system it runs natively.

This is where development containers come in.

## Development containers

Developing, or working in general, inside a container, is nothing new, but has gained popularity and visibility in recent years thanks to the support in Microsoft Visual Studio Code - see the link in the [Further reading](#further-reading) section on developing in containers.

We have been experimenting with describing small Docker images that contain essential command tools for the SAP Business Technology Platform, all pre-installed and ready to go, with a modern shell environment within which to work. The idea is to make this image available for ad hoc use directly, but also to act as a base image upon which to build further task specific or development workflow specific images.

## BTP tools base image

The base image, called `btptools`, is available as an experiment on Docker Hub, and is built from a Dockerfile that describes the installation of the following essential BTP tools:

* [SAP BTP Command Line Interface (btp CLI)](https://tools.hana.ondemand.com/#cloud)
* [SAP BTP, serverless runtime CLI](https://tools.hana.ondemand.com/#cloud)
* [Cloud MTA Build Tool (MBT)](https://sap.github.io/cloud-mta-build-tool/)
* [Cloud Foundry CLI](https://docs.cloudfoundry.org/cf-cli/install-go-cli.html)

If, at the end of this exercise, you want to dig in further to what we've been working on internally, see the link to the internal repository in the [Further reading](#further-reading) section at the end of this exercise.

## Build upon the btptools base image

In this section you'll build upon the `btptools` base image, describing an image that covers the tools used in this hands-on session, i.e. the btp CLI (which is already included in the base image) plus `jq` and `fzf`. You'll then instantiate a container based upon this image and see how easy it is to create and use containers for this sort of work.

Note that for this exercise, you should now switch to working on your own machine, where you have Docker Desktop installed - see the [Docker Desktop](../../README.md#docker-desktop) part of the [Session prerequisites](../../README.md#session-prerequisites) in this hands-on session's main [README](../../README.md) for details.


### Create a Dockerfile for your image description

The following Dockerfile commands describe an image that:

* is based upon the experimental `btptools` image
* adds the `jq` and `fzf` utilities
* adds the Bash shell & specifies it for interactive use

The base image is based on the minimal Docker image [Alpine](https://hub.docker.com/_/alpine) which doesn't have the Bash shell as standard, which is why it's added at this point.

```dockerfile
FROM ruinogueira/btptools:20220110100530

RUN apk add jq fzf bash
WORKDIR /root
RUN touch /root/.bashrc
CMD ["bash"]
```

> The command `RUN touch /root/.bashrc` has been added to allow the `btp enable autocomplete bash` to function (there are no Bash dotfiles in which to save the autocompletion setup otherwise).

👉 Create a new, empty directory, and add a file called `Dockerfile` with this content. Make sure the file you create has no extension (some operating systems may try to add one for you, which you don't want).

### Build the image

👉 Making sure you're in this new directory containing the `Dockerfile` file, build the image, giving it a tag of `ho060` and specifying the directory as the context (this is the `.` at the end of the command, referring to "this directory" - don't forget that):

```
docker build -t ho060 .
```

You should see output showing you that the image is being built - it will look similar to something like this:

```
; docker build -t ho060 .
[+] Building 8.3s (9/9) FINISHED
 => [internal] load build definition from Dockerfile                                                                   0.0s
 => => transferring dockerfile: 159B                                                                                   0.0s
 => [internal] load .dockerignore                                                                                      0.0s
 => => transferring context: 2B                                                                                        0.0s
 => [internal] load metadata for docker.io/ruinogueira/btptools:20220110100530                                         1.8s
 => [auth] ruinogueira/btptools:pull token for registry-1.docker.io                                                    0.0s
 => [1/4] FROM docker.io/ruinogueira/btptools:20220110100530@sha256:997836806a143ccdb58f36d94d1d5f396af2ad9d7542a0b27  4.7s
 => => resolve docker.io/ruinogueira/btptools:20220110100530@sha256:997836806a143ccdb58f36d94d1d5f396af2ad9d7542a0b27  0.0s
 => => sha256:997836806a143ccdb58f36d94d1d5f396af2ad9d7542a0b275c6349c05dbac74 1.58kB / 1.58kB                         0.0s
 => => sha256:036566f952a2a76dd11cacbb460795a76de22ba4be05460ac7b18b2423a8e5e7 1.62kB / 1.62kB                         0.0s
 => => sha256:683f5896f0d993f8734d5696750b8d1bd5a54435bb41fb23f0bdda0d74113264 9.03MB / 9.03MB                         2.0s
 => => sha256:f6c63e2dd22d82b27e1da34ddde2c218198cd132264022f5325e364db48218c1 5.66MB / 5.66MB                         1.8s
 => => sha256:e47af49239fa62aa8b337a7ee35dfcffeec2046f0ccfe5e898649f55cd3a31dc 25.07MB / 25.07MB                       3.7s
 => => sha256:cb42a913b1ded0ef5d1ccf06744079c789824fa67c9cd553c3427618413d3c88 2.92MB / 2.92MB                         2.7s
 => => extracting sha256:683f5896f0d993f8734d5696750b8d1bd5a54435bb41fb23f0bdda0d74113264                              0.3s
 => => extracting sha256:f6c63e2dd22d82b27e1da34ddde2c218198cd132264022f5325e364db48218c1                              0.2s
 => => extracting sha256:e47af49239fa62aa8b337a7ee35dfcffeec2046f0ccfe5e898649f55cd3a31dc                              0.6s
 => => extracting sha256:cb42a913b1ded0ef5d1ccf06744079c789824fa67c9cd553c3427618413d3c88                              0.1s
 => [2/4] RUN apk add jq fzf bash                                                                                      1.5s
 => [3/4] WORKDIR /root                                                                                                0.0s
 => [4/4] RUN touch /root/.bashrc                                                                                      0.2s
 => exporting to image                                                                                                 0.1s
 => => exporting layers                                                                                                0.1s
 => => writing image sha256:fa68f71bfdf764b937b5763aa26910467762962bb93eb08ad2403c8ca5f4cee2                           0.0s
 => => naming to docker.io/library/ho060                                                                               0.0s
```

### Create a container from the image

Now you can create a container based on this image.

👉 Do this now with the following command:

```
docker run --rm -it ho060
```

Here is a brief explanation of the options:

* `--rm` tells Docker to delete the container once it's done with - once you exit the container, it will be removed (if you don't want this to happen, don't use the `--rm` option)
* `-it` is actually `-i` and `-t` combined together, but it's so commonly seen that it's worth sharing it in this way here; `-i` is short for `--interactive` and `-t` is short for `--tty` which tells Docker to allocate a pseudo TTY; together, these options allow you to "enter" the container interactively

Once you've executed the `docker run` command above, you should see a simple prompt appear, like this:

```
bash-5.1#
```

You're now inside the container!

### Try commands out

Now you're in the container, you can try out the BTP commands and utilities that are there for you.

👉 First, log in to the btp CLI and follow the prompts as normal, as you did in the [Authenticating and managing configuration](../02-authenticating-and-configuration/README.md) exercise:

```bash
btp login
```

👉 Now enable autocomplete, as you did in the [Setting up autocomplete and initial account exploration](../03-autocomplete-and-exploration/README.md) exercise:

```bash
btp enable autocomplete bash
```

Rather than restart the terminal (remember that this style of container is ephemeral), simply now source your `.bashrc` file to have the autocomplete commands run in your existing session:

```bash
source $HOME/.bashrc
```

Now you're free to explore and use the btp CLI and related tools, all within a container that you can fire up at any time and anywhere there's a Docker engine.

👉 As an example, list the available regions for your account, requesting the output in JSON, and use `jq` to pick out the display names:

```bash
btp --format json list accounts/available-region 2> /dev/null \
| jq -r .datacenters[].displayName
```

Excellent!

## Summary

In this exercise you've seen a brief glimpse of the power and utility of development containers, and tried one out in the form of a basic "BTP tools" environment. If you're interested in learning more about this initiative, please follow up with Rui Nogueira and DJ Adams.

## Further reading

* [Developing inside a Container](https://code.visualstudio.com/docs/remote/containers)
* [An internal repository providing various Dockerfiles and scripts to embed SAP BTP within (non-SAP) tool chains](https://github.tools.sap/btp-dev-automation/main) - this also contains an overview schematic and a link to a demo video

---

If you finish earlier than your fellow participants, you might like to ponder these questions. There isn't always a single correct answer and there are no prizes - they're just to give you something else to think about.

1. What general and specific development or devops workflows can you think of in your own team that would benefit from such a generalized or tools-focused Docker image?
1. What other benefits can you see from a uniform, consistent and ubiquitous availability of BTP tools?
1. Do you think that partners and customers would also benefit from such a facility?
1. The container you just created is then removed (via the `--rm` option) when you're done. How might you persist information such as the btp CLI configuration, between container sessions?
