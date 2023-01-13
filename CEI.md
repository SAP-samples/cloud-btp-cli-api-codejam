# Working with the btp CLI for account management tasks

This document contains hands-on material for a mini (2 hour) workshop which forms part of a Customer Engagement Initiative (CEI) on the btp CLI. 

It introduces the participants to the facilities of the btp CLI in particular, and to the power of the command line, and to scripting in general. 

## Prerequisites

In order to take part in this initiative, you'll need a global account on SAP Business Technology Platform (SAP BTP) for which you have administrative access. One option here is to use a [trial account](https://www.sap.com/products/technology-platform/trial.html); if you don't have one, you can sign up for one now, and it's free. While the activities can be carried out in any global account for which you have administrative access, the examples in this document will be based on such a trial account. 

You'll also need an environment within which to work. For this you have two options, and these are the same options that are valid for this workshop's bigger sibling, the SAP CodeJam on the btp CLI and APIs. 

The options are, briefly - a basic Dev Space in the SAP Business Application Studio, or if you prefer to use a container image, Docker Desktop. Detailed instructions for both these options can be found in the SAP CodeJam's [prerequisites](/prerequisites.md) document. If you're going for the container image option, be sure to work through the [container/](container/) instructions for obtaining the Dockerfile, building the image, and running a container from that image.

## Participation

The workshop will be remote and led by an instructor. But all the activities are detailed below, so you can run through them after the workshop too if you wish. Where there's something you actually have to do (such as examine something, or type something in), this will be indicated with the 👉 symbol.

## Activities

This is the main part of the document and contains all the activities that you'll work through in the workshop. The starting point for these activities is with you in your Dev Space in the SAP Business Application Studio, with a terminal opened (use the menu path Terminal -> New Terminal), or in a container.

### Getting the btp CLI

The btp CLI tool is available from the [SAP Development Tools](https://tools.hana.ondemand.com/) website, specifically in the [Cloud](https://tools.hana.ondemand.com/#cloud) section. While there are retrieval and installation instructions on the download page, there's a script you can run that will do this for you, to save time.

This script is part of an [SAP Tech Bytes](https://github.com/SAP-samples/sap-tech-bytes) topic, specifically [SAP btp CLI](https://github.com/SAP-samples/sap-tech-bytes/tree/2021-09-01-btp-cli), and is available in the corresponding branch: [getbtpcli](https://github.com/SAP-samples/sap-tech-bytes/blob/2021-09-01-btp-cli/getbtpcli).

👉 Make sure you're in your home directory, then download this script and make it executable, and then run it:

```bash
cd $HOME \
  && curl \
    --remote-name \
    --location \
    --url "https://raw.githubusercontent.com/SAP-samples/sap-tech-bytes/2021-09-01-btp-cli/getbtpcli" \
  && chmod +x getbtpcli \
  && yes | ./getbtpcli 
```

You should end up with an executable `btp` in a `bin/` directory local in your home directory.

👉 Add this `bin/` directory to your `PATH` so you can invoke `btp` without having to specify where it is:

```bash
echo 'export PATH=$PATH:$HOME/bin' >> $HOME/.bashrc \
  && source <(tail -1 $HOME/.bashrc)
```

OK, now you can run `btp` for the first time. 

👉 Try it now:

```bash
btp
```

You should see some output that looks like this:

```text
SAP BTP command line interface (client v2.33.0)

Usage: btp [OPTIONS] ACTION GROUP/OBJECT PARAMS

CLI server URL:                    https://cpcli.cf.eu10.hana.ondemand.com (server v2.35.0)
Configuration:                     /home/user/.config/btp/config.json

You are currently not logged in.

Tips:
    To log in to a global account of SAP BTP, use 'btp login'. For help on login, use 'btp help login'.
    To provide feedback about the btp CLI, use 'btp feedback' to open our survey.
    To display general help, use 'btp help'.

```

Great! You're now ready to wield the power of the btp CLI.


