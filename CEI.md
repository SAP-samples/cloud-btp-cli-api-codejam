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

### Get the btp CLI 

*5 mins*

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

Now it's time to log in.

👉 Use the basic form as shown here, (or use the `--sso manual` option), and follow the prompts:

```bash
btp login
```

Great! Now that you're logged in, you're ready to wield the power of the btp CLI.

### Turn on and try out autocomplete

*5 mins*

If you're going to become a power user with the btp CLI you cannot do without the autocomplete facilities that it offers. 

👉 Set up autocomplete by running this invocation, confirming that you want to continue, and choosing option 2 (for `/home/user/.bashrc`):

```bash
btp enable autocomplete bash
```

In what is emitted, there's a note that says that you "must start a new terminal to activate the installed script". There's a way around that, which we'll use here, which is just to execute the latest line that's been added to your `$HOME/.bashrc` file by the autocomplete installation process. 

👉 Do this now (you may recognize the invocation from earlier when you added the `bin/` directory to your `PATH`):

```bash
source <(tail -1 $HOME/.bashrc)
```

Now you can try out autocomplete. Type in the `btp` command and hit the Tab key, to explore the actions and objects. Here's an example of such exploration, to give you an idea.

![animated demonstration of btp CLI autocomplete](https://blogs.sap.com/wp-content/uploads/2021/09/autocomplete.gif)

At this point you should take a few minutes to explore; you'll likely get results quickly if you focus on the `list` action and pick objects that present themselves for that, for example `btp list accounts/available-region` or `btp list security/role-collection`.

### Display the global account hierarchy and make an alias

*5 mins*

A really useful `btp` invocation is the one to display the global account details, and include with that a simple hierarchical display.

👉 Run that now, and stare at the output for a second to get used to it:

```bash
btp get accounts/global-account --show-hierarchy
```

> This is the first action you've run where you've used a parameter (`--show-hierarchy`).

The output should look something like this (or have more detail if you're using something other than a fresh trial account):

```text
howing details for global account 06de8b78-0e1d-48a5-9323-97824c99671f...

├─ 65137137trial (06de8b78-0e1d-48a5-9323-97824c99671f - global account)
│  ├─ trial (b07f7316-2d2a-445a-8fcc-a52952c92607 - subaccount)

type:            id:                                    display name:   parent id:                             parent type:    
global account   06de8b78-0e1d-48a5-9323-97824c99671f   65137137trial                                                          
subaccount       b07f7316-2d2a-445a-8fcc-a52952c92607   trial           06de8b78-0e1d-48a5-9323-97824c99671f   global account  

```

You'll probably find that this is such a useful output that you'll want to run this command over and over again. 

👉 So create an alias for it:

```bash
alias btphier='btp get accounts/global-account --show-hierarchy'
```

> This time we won't bother putting this into your `$HOME/.bashrc`, but in a real environment you would definitely want to saev your alias definitions somewhere.

👉 Try this alias out:

```bash
btphier
```

That's easier, right?

### Set the target to a subaccount

*10 mins*

Many btp CLI actions target a subaccount or directory. So when invoking such an action, you'll often need to specify which subaccount or directory you want the action to affect. This is normally done via the use of parameters in the action invocation. 

However, there's a better way, with the target facility. 

👉 Invoke `btp` on its own right now, and have a look at the output:

```bash
btp
```

Part of the output shows you what the current target is, and will look something like this:

```text
Current target:
  65137137trial (global account, subdomain: 65137137trial-ga)
```

This means that right now you're just targeting the global account and you are not targeting any directory or subaccount.

So now you should set the target to the subaccount that you have; you'll have seen this subaccount listed in the hierarchical display earlier.

There are three different approaches. All use the `btp target` invocation, but in different ways.

The first approach is rather manual, and you'll need to do some copy/pasting. It involves using the `--subaccount` parameter and explicitly specifying the GUID of the subaccount you want to target. So first you need to get the GUID (for example via your new alias `btphier`), then use that in the invocation. This is what the process looks like:

```text
user: user $ btphier

Showing details for global account 06de8b78-0e1d-48a5-9323-97824c99671f...

├─ 65137137trial (06de8b78-0e1d-48a5-9323-97824c99671f - global account)
│  ├─ trial (b07f7316-2d2a-445a-8fcc-a52952c92607 - subaccount)

type:            id:                                    display name:   parent id:                             parent type:    
global account   06de8b78-0e1d-48a5-9323-97824c99671f   65137137trial                                                          
subaccount       b07f7316-2d2a-445a-8fcc-a52952c92607   trial           06de8b78-0e1d-48a5-9323-97824c99671f   global account  


OK

user: user $ btp target --subaccount b07f7316-2d2a-445a-8fcc-a52952c92607
Targeting subaccount 'b07f7316-2d2a-445a-8fcc-a52952c92607'.

Current target:
  65137137trial (global account, subdomain: 65137137trial-ga)
  └─  trial (subaccount, ID: b07f7316-2d2a-445a-8fcc-a52952c92607)

Tips:
    To execute a command in the parent directory or global account, use the '-ga' or '-dir' parameter without value.
    To override the target for a specific command, specify the subaccount, directory, or global account as parameter.

OK

```

A more comfortable and interactive approach is to let `btp` help you choose. 

👉 Do this now:

```bash
btp target
```

Here's an example of how that works, where you can see how `btp` presents options to you:

```text
user: user $ btp target

Current target:
  65137137trial (global account, subdomain: 65137137trial-ga)

Choose subaccount or directory:
  [..]  Switch Global Accounts
   [.]  65137137trial (global account)
   [1]  └─  trial (subaccount)
Choose, or hit ENTER to stay in '65137137trial' [.]> 1

Now targeting:
  65137137trial (global account, subdomain: 65137137trial-ga)
  └─  trial (subaccount, ID: b07f7316-2d2a-445a-8fcc-a52952c92607)

OK

```

Another approach is to use a script. This is included to give you an idea of what's possible. The `bgu` script is described in a couple of blog posts in the [Further reading section of exercise 2 in the main CodeJam content](exercises/02-authenticating-and-configuration/README.md#further-reading) ("Getting BTP resource GUIDs with the btp CLI" parts 1 and 2), and uses the JSON output format that is available as a more predictable and machine-parseable alternative for scripting and more. We'll take a look at that JSON output format shortly!

