# Exercise 03 - Setting up autocomplete and initial account exploration

At the end of this exercise, you'll have autocomplete turned on for the btp CLI and have a general overview of your BTP account and what resources are available.

## Understand btp CLI command scope

If you've had a look at the output from `btp help` you'll know that there are multiple commands that the CLI supports, and different groups of objects upon which these commands operate:

```text
SAP BTP command line interface (client v2.83.0)

Usage: btp [OPTIONS] ACTION GROUP/OBJECT PARAMS

Each GROUP contains multiple OBJECTS, on which you can perform ACTIONS.

ACTIONS:
    list, get, create, update, delete, add, remove, assign, unassign, enable,
    move, register, unregister, subscribe, unsubscribe, share, unshare, migrate,
    restore, rotate

GROUPS:
    accounts  Objects related to the account model, subscriptions, and environments
    security  Authorization objects and users
    services  Objects related to SAP Service Manager

Example help calls:
    btp help list                                 Commands for ACTION "list"
    btp help accounts                             Objects in GROUP "accounts"
    btp help accounts/available-environment       Actions for OBJECT "available-environment"
    btp help list accounts/available-environment  Command-specific help
    btp help all                                  Overview of all commands

General actions:
    help                  Display help
    feedback              Give us feedback
    login                 Log in to a global account of SAP BTP
    logout                Log out from SAP BTP
    target                Set the target for subsequent commands
    enable autocomplete   Enable command autocompletion
    disable autocomplete  Disable command autocompletion
    list config           List current configuration settings
    set config            Change configuration settings
    reset config          Change configuration settings to default values

Options:
  --config   Specify location of configuration file
  --format   Change output format. Valid values: text (default), json
  --help     Display help
  --info     Show version and current context
  --verbose  Print tracing information for support
  --version  Print client version

Documentation:
    Command Reference: https://help.sap.com/docs/btp/btp-cli-command-reference/btp-cli-command-reference
    Get Started: https://developers.sap.com/tutorials/cp-sapcp-getstarted.html
    Concepts and How-Tos: https://help.sap.com/docs/btp/sap-business-technology-platform/account-administration-using-sap-btp-command-line-interface-btp-cli
```

It's possible to get an overview of what the possible targets of each command are, by asking for help on that particular command.

👉 Try it now, asking for help with the "list" action:

```bash
btp list --help
```

Here's the sort of output that you'll see:

```text
SAP BTP command line interface (client v2.83.0)

Usage: btp [OPTIONS] ACTION GROUP/OBJECT PARAMS

Available "list" commands:
    btp list accounts/available-environment  Show all available environments for a subaccount
    btp list accounts/available-region       Show all available regions for a global account
    btp list accounts/custom-property        Deprecated. Show all custom properties
    btp list accounts/entitlement            Show all the entitlements and quota assignments
    btp list accounts/environment-instance   Show all environment instances of a subaccount
    btp list accounts/label                  Show all user-defined labels of a subaccount or directory
    btp list accounts/resource-provider      Show all resource provider instances
    btp list accounts/subaccount             Show all subaccounts in a global account
    btp list accounts/subscription           Show all applications to which a subaccount is entitled to subscribe
    btp list config                          List current configuration settings
    btp list security/api-credential         Show all security API credentials for API access
    btp list security/app                    Show all apps
    btp list security/available-idp          Show all available SAP Cloud Identity Services tenants
    btp list security/role                   Show all roles
    btp list security/role-collection        Show all role collections
    btp list security/settings               Show the security settings of a global account or subaccount
    btp list security/token-key              Show all signing keys for access tokens
    btp list security/trust                  Show all trust configurations
    btp list security/user                   Show all users
    btp list services/binding                Show all service bindings
    btp list services/broker                 Show all service brokers
    btp list services/instance               Show all service instances
    btp list services/offering               Show all service offerings
    btp list services/plan                   Show all service plans
    btp list services/platform               Show all platforms

Example of command-specific help:
    btp help list accounts/available-environment
```

> You can also use this style of help invocation too: `btp help list`.

But there's a much more comfortable way, and that's having the btp CLI itself suggest what's possible to you as you feel your way into what you want to do. This is a very common pattern and feature in shells such as Bash, and many command line programs offer such a facility, which is commonly referred to as "autocomplete".

## Set up autocomplete

In the output from `btp help` you'll have already seen how to do this: `btp enable autocomplete`. Asking for help on this (`btp enable autocomplete --help` or `btp help enable autocomplete`) will give you lots of details, one of which is that you need to specify the shell for which to enable the autocomplete feature. Within our Dev Space in App Studio (and also in the container if you're taking that route) we're enjoying The-One-True-Shell™, i.e. [Bash](https://en.wikipedia.org/wiki/Bash_(Unix_shell)) :-).

👉 Set up autocomplete now, selecting `/home/user/.bashrc` (option 2) for the RCFile:

```bash
btp enable autocomplete bash
```

Here's an example of such a setup:

```text
user: user $ btp enable autocomplete bash
Which RCFile should be used for the installation?
1: /home/user/.bash_profile
2: /home/user/.bashrc
3: /home/user/.profile
4: Custom
Enter option> 2
Autocomplete script for bash has been installed to /home/user/.bashrc.
You must start a new terminal session to activate the installed script.

Tips:
  Use the TAB key to complete commands and provide valid command actions, options, and parameters.
  Use the TAB key to cycle through the suggestion lists and the ENTER key to select.

OK
```

Note that a script has been installed to your btp CLI configuration directory, and the `.bashrc` file was chosen to contain the autocomplete setup (the invocation of that script on shell startup). This is recommended.

👉 Have a look what was added by looking at the last few lines of the `.bashrc` file like this:

```bash
tail $HOME/.bashrc
```

You'll see towards the end of the output that there are extra lines that follows the two lines you yourself added in earlier exercises:

```bash
alias bu='source <(tail -1 /home/user/.bashrc)'
export PATH=$PATH:$HOME/bin
export BTP_CLIENTCONFIG=$HOME/.config/btp/config.json
### Begin SAP BTP command line interface autocomplete
eval "$(btp --autocomplete=init:bash)"
### End SAP BTP command line interface autocomplete
```

👉 The `eval` line, which does the heavy lifting to enable autocompletion for `btp`, is surrounded by a comment line above and below. Our simple `bu` [alias](../01-installing#set-an-alias-to-invoke-new-bashrc-commands) only operates on the last line in the `.bashrc` file, so before running it to have this update take effect, remove the last line (the `### End SAP BTP command line interface autocomplete` one) with:

```bash
sed -i '$d' $HOME/.bashrc
```

👉 Now invoke the update with `bu` to have it take effect immediately:

```bash
bu
```

## Try out autocomplete

Now you're ready to try the autocomplete feature out.

👉 Start by typing `btp` (followed by a space) and then hitting `Tab`. You'll first see the possible commands. Choose one by starting to type it and autocompleting it with `Tab`, and then choose from the list of GROUP / OBJECTs presented. You should spend a minute or two exploring like this - it's much easier to get a feel for autocomplete by trying it, rather than reading about it. But in case you want to read more about it, see the link to the blog post in the [Further reading](#further-reading) section below, which is from where this animated demonstration comes:

![animated demonstration of btp CLI autocomplete](assets/autocomplete.gif)

## Explore your BTP account

You have everything set up to be able to explore your BTP account; you can invoke the btp CLI from wherever you are, you're logged in, you have your global account and "trial" subaccount targeted, and you have autocomplete turned on for the most comfortable experience.

> The authentication token has a limited lifetime, so you may have to re-authenticate at some stage with `btp login`.

It's time to explore your account and related BTP resources.

👉 Spend a few minutes trying some of these commands, and examining the output:

|Action|Group/Object|Description|
|-|-|-|
|`get`|`accounts/global-account`|A high level summary of the key information for your global account; add the parameter `--show-hierarchy` to get a depiction of the relationship between the directories & subaccounts within|
|`list`|`accounts/entitlement`|A list of the entitlements for your targeted subaccount|
|`list`|`accounts/available-region`|A list of the regions & providers available for your global account|
|`list`|`security/role-collection`|A list of role collections available in your account|

> Notice again that the general pattern of plural GROUP and singular OBJECT components is evident here too.

## Summary

At this point you have autocomplete working and you should feel comfortable invoking the btp CLI from the command line and exploring resources relating to your BTP account.

## Further reading

* [SAP Tech Bytes: btp CLI – autocompletion](https://community.sap.com/t5/technology-blogs-by-sap/sap-tech-bytes-btp-cli-autocompletion/ba-p/13503134)
* [SAP Help topic: Enable Command Autocompletion](https://help.sap.com/docs/btp/sap-business-technology-platform/enable-command-autocompletion)

---

## Questions

If you finish earlier than your fellow participants, you might like to ponder these questions. There isn't always a single correct answer and there are no prizes - they're just to give you something else to think about.

1. How would you discover or confirm that the shell you're actually using is indeed a Bash shell?
1. Output for some of the commands you used in exploring your account probably wrapped over multiple lines. How might you remedy that?

---

[Next exercise](../04-retrieving-parsing-json-output/README.md)
