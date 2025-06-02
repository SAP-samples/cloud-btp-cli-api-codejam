# Exercise 02 - Authenticating and managing configuration

At the end of this exercise, you'll have successfully authenticated with the btp CLI for your SAP BTP account and know about what configuration there is & how to control where it's kept.

## Gather the information required

To authenticate with the btp CLI so you can access and manage the resources in your BTP account, you need certain items of information.

👉 Make sure you have the username and password with which you log on to your BTP account. You may also need to know your global account subdomain, if your user has access to more than one, and you have to choose.

You can see an example of the subdomain for this sample trial global account, just underneath the "Account Explorer" heading:

![trial global account showing subdomain](assets/global-account-subdomain-and-subaccount.png)

## Authenticate

If you managed to check out the "Usage" information and the output from `btp help` [at the end of the previous exercise](../01-installing/README.md#questions) you'll have seen that there are "General actions" as well as BTP resource specific actions. One of these general actions is "login".

👉 Use that now to authenticate, supplying the information you gathered in the previous section:

```bash
btp login
```

Here's an example authentication flow for a user with just a single trial global account 65137137trial:

```text
SAP BTP command line interface (client v2.83.0)

CLI server URL [https://cli.btp.cloud.sap]>
Connecting to CLI server at https://cli.btp.cloud.sap...

Server certificate subject: CN=cli.btp.cloud.sap,O=SAP SE,L=Walldorf,ST=Baden-Württemberg,C=DE
Server certificate fingerprint: fdcf5777236368230da5adc18e38808307fb79c1b1dd240bb71523645d0efc56

User> dj.adams@sap.com
Password>

Authentication successful

Current target:
 013e7c57trial (global account, subdomain: 013e7c57trial-ga)

We stored your configuration file at: /home/user/.config/.btp/config.json

Tips:
    Commands are executed in the target, unless specified otherwise using a parameter. To change the target, use 'btp target'.
    To provide feedback about the btp CLI, use 'btp feedback' to open our survey.

OK
```

> Earlier versions of the btp CLI required you to always specify your global account subdomain, but now it will try to discern it from your user details. Additionally, the value for the "CLI server URL" is fixed (`https://cli.btp.cloud.sap`) and you shouldn't need to change it.

If your user is associated with more than one global account, they will be presented to you and you must choose one of them. Here's an example of that additional section of the flow, that occurs after successful authentication:

```text
Choose a global account:
  [1] 013e7c57trial
  [2] Developer Advocates
  [3] Developer Destination
  [4] Global Dev Rels Prod
  [5] SAP4GOOD
Choose option> 1

Current target:
 013e7c57trial (global account, subdomain: 013e7c57trial-ga)
```

It's also possible to use single sign on (SSO) with the browser, using the `--sso manual` option (i.e. `btp login --sso manual`). Here's what that section of the flow looks like, in place of the `User>` and `Password>` prompts:

```text
Please authenticate at: https://cli.btp.cloud.sap/login/v2.83.0/browser/4014ee3a-7893-49a0-a4dc-c027a26773e6
```

> In this example, the user selects the URL presented at the "Please authenticate at" prompt and opens it in the browser, and authenticates there if required. Then the flow automatically continues.

Any issues logging in could be down to a number of factors - for example, if you're using two-factor authentication (2FA), remember to append your 2FA code to your password as you enter it.

## Set your desired subaccount as a target

It's likely that you'll often be wanting to work with some of your SAP BTP resources at the subaccount level. In a trial global account, this is the "trial" subaccount that's automatically created (you can see an example of this "trial" subaccount in the screenshot earlier). It will be different in other accounts.

> The examples in this section will continue to use the trial subaccount but you should follow along using [whatever subaccount you have identified for this CodeJam](../../prerequisites.md#subaccount-and-cloud-foundry-environment). A subaccount is where you'll be normally operating - where you'll have environment instances (Cloud Foundry or Kyma runtimes, for example). Think of a global account as a container for multiple subaccounts.

Rather than have to specify this subaccount each time in various btp CLI invocations, you can tell the btp CLI once, with the `target` general action, and then it will be used when required.

You can find out more about the `target` action, and any action, with the general action `help`, i.e. `btp help target`.

👉 Do this now, and examine the output:

```bash
btp help target
```

Here's an example invocation:

```text
Usage: btp [OPTIONS] target [--hierarchy [BOOL]] [--global-account SUBDOMAIN] [--directory ID] [--subaccount ID]

Set the target for subsequent commands.

Set the target for commands to a global account, a directory, or a subaccount. Commands are executed in the specified target, unless you override it using a parameter.
If the specified target is part of an account hierarchy, its parents are also targeted, so that if a command is only available on a higher level, it will be executed there.

For a simple target selection, use 'btp target' without parameters. The siblings and children of your current target will be displayed for selection, and you can navigate up and down within the hierarchy.

To see the entire hierarchy of all global accounts as well as the included directories and subaccounts, use the '--hierarchy' parameter. You can then select a target from this list.

Parameters:
  --hierarchy,-h [BOOL]           (Optional) Browse the entire hierarchy of all global accounts to select a target.
  --global-account,-ga SUBDOMAIN  (Optional) You can omit SUBDOMAIN as only the global account of the active login can be targeted.
  --directory,-dir ID             (Optional) The ID of the directory to be targeted.
  --subaccount,-sa ID             (Optional) The ID of the subaccount to be targeted.

Tips:
    To execute a command in the parent directory or global account, use the '-ga' or '-dir' parameter without value.
    To find a subaccount ID, use 'btp list accounts/subaccount'.
    To find a directory ID, use 'btp get accounts/global-account --show-hierarchy'.

Further documentation:
    https://help.sap.com/docs/btp/sap-business-technology-platform/set-target-for-subsequent-commands-with-btp-target
```

So set your desired subaccount as the target now.

👉 Try this (substituting your subaccount's name for "trial", if it's different):

```bash
btp target --subaccount trial
```

Hmm, that's not quite right, is it?

Here we see there's a distinction between the display name and the ID. The help above, as well as the error message you just saw as a result of not actually specifying a real ID, gives us a clue as to how we find it.

👉 Do that now, using the "list" action on the "subaccount" object in the "accounts" group:

```bash
btp list accounts/subaccount
```

Here's the sort of thing that you should see:

```text
user: user $ btp list accounts/subaccount

subaccounts in global account ca405764-53fa-4a0c-a108-2bf9029d96db...

subaccount id:                         display name:   subdomain:      region:   beta-enabled:   parent id:                             parent type:     state:   state message:
1b03e737-789b-4c9c-840c-0f50e1ded13d   trial           013e7c57trial   us10      false           ca405764-53fa-4a0c-a108-2bf9029d96db   global account   OK       Subaccount created.


OK
```

> By the way, here's where the plural/singular approach to the group and object in the invocation comes in (we thought about this at the end of the previous exercise). In the `btp` invocation you just made, group "accounts" is plural, while the object "subaccount" is singular.

The output should include a detailed line for your subaccount, showing its ID (which starts `b07f7316` here - the ID for your subaccount will of course be different) as well as its name (which is `trial` in this example).

👉 Try the `target` command again, this time specifying the ID of your subaccount, rather than the display name. Here's an example, with output:

```text
user: user $ btp target --subaccount 1b03e737-789b-4c9c-840c-0f50e1ded13d
Targeting subaccount '1b03e737-789b-4c9c-840c-0f50e1ded13d'.

Current target:
 013e7c57trial (global account, subdomain: 013e7c57trial-ga)
  └─ trial (subaccount, ID: 1b03e737-789b-4c9c-840c-0f50e1ded13d)

Tips:
    To execute a command in the parent directory or global account, use the '-ga' or '-dir' parameter without value.
    To override the target for a specific command, specify the subaccount, directory, or global account as parameter.

OK
```

Any `btp` invocation output will include what the current target is; note now that not only is the global account targeted but also the subaccount:

```text
Current target:
 013e7c57trial (global account, subdomain: 013e7c57trial-ga)
  └─ trial (subaccount, ID: 1b03e737-789b-4c9c-840c-0f50e1ded13d)
```

> You can make your command line life more comfortable with custom functions and scripts, such as one to get the ID for a subaccount, given its display name. We'll cover this in [a later exercise in this session](../05-btp-guids-cli-in-practice/README.md). See also [the `bgu` script in action as part of the btp CLI section of the 2021 SAP TechEd Developer Keynote](https://youtu.be/OmEx598qAI8?t=180) and also the two related blog posts in the [Further reading](#further-reading) section below.

**Note**

With version 2.33.0 of the btp CLI, a new "interative target" feature was introduced. You can try this out simply by entering `btp target` and following the instructions, which will display the hierarchy of directories and subaccounts available to you in the global account you're currently in, and allow you to navigate that hierarchy and select a new target. Here's an example:

```text
user: user $ btp target

Current target:
 013e7c57trial (global account, subdomain: 013e7c57trial-ga)
  └─ trial (subaccount, ID: 1b03e737-789b-4c9c-840c-0f50e1ded13d)

Choose subaccount or directory:
  [..] Switch Global Accounts
   [.] 013e7c57trial (global account)
   [1]  └─ trial (subaccount)
Choose, or hit ENTER to stay in 'trial' [1]>
```

## Find and organize your btp CLI configuration

Directly after logging in just a few moments earlier, you may have noticed that the success message included a line about configuration (see the [Authenticate](#authenticate) section earlier for the context):

```text
We stored your configuration file at: /home/user/.config/.btp/config.json
```

> You can also see this configuration information in the output shown when you invoke `btp` on its own.

This configuration file holds information about your current session, for example the details of any current target you have. Feel free to have a look at this file (the simplest way would be to use `cat`, i.e. `cat /home/user/.config/.btp/config.json` but you could also use `jq`, i.e. `jq . /home/user/.config/.btp/config.json`). Don't worry about showing the contents to anyone - it doesn't contain any session tokens that are used to authorize your btp CLI activities - this information is elsewhere (see later in this section to find out where).

You can see from the message above that the default configuration location is within a btp CLI specific directory in a `$HOME/.config/` directory. This is nice because it conforms to an open standard (the [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)) and specifically the default value of `XDG_CONFIG_HOME`.

The SAP Help topic [Specify the Location of the Configuration File](https://help.sap.com/docs/btp/sap-business-technology-platform/specify-location-of-configuration-file) explains how you can override this default location either with the `--config` option or by specifying the location in the environment variable `BTP_CLIENTCONFIG`.

If you're like me, you may like to organize your configuration files within `$HOME/.config/` as non-hidden directories, so having a directory called `$HOME/.config/.btp/` may be less than ideal. So if this is something you also feel strongly about, use this step to address it.

> Files or directories with names starting with a period (`.`) are considered "hidden", as they won't show up in any listing, unless you explicitly ask for them to be shown (incidentally, this well-known and almost universal feature [started out as a mistake due to a programming shortcut with unintended consequences](https://web.archive.org/web/20180827160401/https://plus.google.com/+RobPikeTheHuman/posts/R58WgWwN9jp)). While it's fairly common to have the `$HOME/.config/` directory itself as a hidden directory, it makes more sense to want to be able to easily see what subdirectories are in there - for what programs and systems you have configuration.

### Rename the config directory

👉 First, rename the actual `.btp/` directory to `btp/` so it's not a hidden directory any more:

```bash
mv $HOME/.config/.btp/ $HOME/.config/btp/
```

### Specify a permanent value for `BTP_CLIENTCONFIG`

👉 Now append another line to your `.bashrc` file to set the `BTP_CLIENTCONFIG` environment variable to our new preferred location (again, be sure to use the `>>` append redirection operator so you don't truncate the file and use single quotes where and as shown):

```bash
echo 'export BTP_CLIENTCONFIG=$HOME/.config/btp/config.json' >> $HOME/.bashrc
```

Using the `bu` alias will cause this new environment variable to be set in your current shell, so you can then try invoking `btp` again.

👉 Do that now, and then check that the environment variable is indeed set appropriately:

```bash
bu
env | grep BTP
```

### Log back in again with btp login

Session tokens, which are used to authorize btp CLI calls, are not stored in the configuration file. They're stored in a directory within `$HOME/.cache/.btp/`, in a session file that's readable only by you. The exact location depends on the path to your configuration file (the directory name is a hash of that path), so now we've moved that, we need to log in one more time to have a fresh session token stored in a new directory within `$HOME/.cache/.btp/`.

👉 Log in again:

```bash
btp login
```

Once you've logged in again, you should be all set.

> If you're interested to see where this session information is stored, take a look in `$HOME/.cache/.btp/`.

Great - the configuration is now in a non-hidden `btp/` subdirectory within your `$HOME/.config/` directory, and all is well with `btp`.

## Summary

At this point you've logged in with `btp` and have your global account and "trial" subaccount targeted. You've also seen what the client configuration looks like, and how to control its location.

## Further reading

* [SAP Tech Bytes: btp CLI – logging in](https://community.sap.com/t5/technology-blogs-by-sap/sap-tech-bytes-btp-cli-logging-in/ba-p/13519378)
* [SAP Tech Bytes: btp CLI – managing configuration](https://community.sap.com/t5/technology-blogs-by-sap/sap-tech-bytes-btp-cli-managing-configuration/ba-p/13496400)
* [Getting BTP resource GUIDs with the btp CLI – part 1](https://community.sap.com/t5/technology-blogs-by-sap/getting-btp-resource-guids-with-the-btp-cli-part-1/ba-p/13511167)
* [Getting BTP resource GUIDs with the btp CLI – part 2 – JSON and jq](https://community.sap.com/t5/technology-blogs-by-sap/getting-btp-resource-guids-with-the-btp-cli-part-2-json-and-jq/ba-p/13517574)
* [Redirections in Bash](https://www.gnu.org/software/bash/manual/html_node/Redirections.html) (to explain `>>` and related operators)
* [Booting our 2022 live stream series with a review of Developer Keynote btp CLI scripting](https://www.youtube.com/watch?v=1jekfZJ3fTk)
* [Managing technical users for BTP platform access](https://community.sap.com/t5/technology-blogs-by-members/managing-technical-users-for-btp-platform-access/ba-p/13521814)

---

## Questions

If you finish earlier than your fellow participants, you might like to ponder these questions. There isn't always a single correct answer and there are no prizes - they're just to give you something else to think about.

1. Why were you told to use single quotes when echoing text into the `.bashrc` file? What would have happened if you'd use double quotes?
1. Did you try to authenticate using Single Sign-On (SSO)? How did it work for you? What about from within a container?

---

[Next exercise](../03-autocomplete-and-exploration/README.md)
