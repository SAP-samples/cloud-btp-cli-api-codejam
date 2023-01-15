# Working with the btp CLI for account management tasks

This document contains hands-on material for a mini (2 hour) workshop which forms part of a Customer Engagement Initiative (CEI) on the btp CLI. 

It introduces the participants to the facilities of the btp CLI in particular, and to the power of the command line, and to scripting in general. 

## Prerequisites

In order to take part in this initiative, you'll need a global account on SAP Business Technology Platform (SAP BTP) for which you have administrative access. One option here is to use a [trial account](https://www.sap.com/products/technology-platform/trial.html); if you don't have one, you can sign up for one now, and it's free. While the activities can be carried out in any global account for which you have administrative access, the examples in this document will be based on such a trial account. 

You'll also need an environment within which to work. We ask that you set up a basic Dev Space in the SAP Business Application Studio. This will provide all participants with a consistent command line environment (a Bash shell) as well as a visual editor and file explorer.

Detailed instructions for these requirements can be found in the SAP CodeJam's [prerequisites](/prerequisites.md) document (you can ignore the specific requirement for the Cloud Foundry environment and the Docker Desktop section).

## Participation

The workshop will be remote and led by an instructor. But all the activities are detailed below, so you can run through them after the workshop too if you wish. Where there's something you actually have to do (such as examine something, or type something in), this will be indicated with the 👉 symbol.

The flow of the workshop will be as follows:

|Duration|Description|
|-|-|
|05 mins|Introduction and orientation|
|05 mins|Get the btp CLI|
|05 mins|Turn on and try out autocomplete|
|05 mins|Display the global account hierarchy and make an alias|
|10 mins|Set the target to a subaccount|
|30 mins|Explore and parse the JSON output|
|50 mins|Build a script to manage directories|
|10 mins|Wrap up and discussion|

## Activities

This is the main part of the document and contains all the activities that you'll work through in the workshop. The starting point for these activities is with you in your Dev Space in the SAP Business Application Studio, with a terminal opened.

👉 To get set up in the Dev Space ready to work through the activities, use the "Files & Folders" start option and select to open the folder "/home/user/" as prompted.

👉 Next, access the menu via the ☰ symbol and open a new terminal with menu path "Terminal -> New Terminal" (you may wish to increase the vertical space a little by dragging up the horizontal rule above it). This should present you with a prompt that looks like this:

```text
user: user $
```

You're all set.

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

> This time we won't bother putting this into your `$HOME/.bashrc`, but in a real environment you would definitely want to save your alias definitions somewhere.

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

### Explore and parse the JSON output

*30 mins*

The default output from the btp CLI is designed to be primarily human readable. 

👉 Try this out, requesting a list of service plans:

```bash
btp list services/plan
```

You should see a list of plans, one per line, with lots of columns:

```text
name                    shareable description                                                                                          free      id                                   service_offering_id                  service_offering_name
application             <null>    Application plan to be used for business applications                                                true      952cebb5-d773-4f54-9da8-c2c442da45c9 f3a2f2fa-2617-4850-8b91-17c57015dcfe xsuaa
broker                  <null>    Broker plan to be used by business reuse services / service brokers                                  true      f156749c-4083-4b4a-8f38-0a49fb38bbb7 f3a2f2fa-2617-4850-8b91-17c57015dcfe xsuaa
standard                <null>    Provides programmatic access to Cloud Transport Management.                                          true      62d209cd-6785-41aa-91e4-684c9779a15c e3381d53-3121-4b89-aa01-655e668ff52a transport
lite                    <null>    Read and manage destination configurations (including related certificates) on account and servic... true      df2addb2-70ce-4a66-bfd2-079aafa17b09 54943912-60f3-4671-b4ca-b60ce24eb1c1 destination
standard                <null>    Allows consumption of SAP Alert Notification service events as well as posting custom events         false     1a92101d-2e60-46f8-b41d-63489003dcd3 6f3240fe-c9f9-4b7e-b8a5-7528269106a2 alert-notification
lite                    <null>    Feature Flags service development plan (for non-productive usage)                                    true      03d708bd-65c6-422e-83e4-48f8489ef672 bd5d9d23-96ce-409b-bb93-7c9225c4e56b feature-flags
default                 <null>    Default plan for Auditlog API                                                                        true      a50128a9-35fc-4624-9953-c79668ef3e5b 4716dd8a-dff6-4063-ae00-776f538ab1cd auditlog-management
app-host                <null>    Use this service plan to deploy HTML5 applications to the repository.                                true      1ccea149-d04d-45f6-8025-271b3a3d15a7 3335c91b-8e02-4a2c-9687-9bc86c0856e5 html5-apps-repo
app-runtime             <null>    Use this service plan to consume HTML5 applications stored in the repository.                        true      fee0c262-5f9b-4ea2-8db5-6604b24f1b65 3335c91b-8e02-4a2c-9687-9bc86c0856e5 html5-apps-repo
application             <null>    Service plan for SaaS application owners to manage the lifecycle of SaaS applications with SAP Sa... true      3a17581c-e9cc-4fa9-ab9c-c9baf5cc854a fe44bf37-25f3-453a-8f6a-06974edeb528 saas-registry
central                 <null>    Service plan for using Cloud Management APIs to manage your global accounts, subaccounts, directo... true      a5fb1a8f-b16e-4135-833e-c4e313c22b04 f8196fd2-f3fa-4f08-8831-1a5af95fe2db cis
local                   <null>    Service plan for using Cloud Management APIs to manage your environments and subscriptions to mul... true      86f508c2-9d0a-45d1-8175-5316ca791ebb f8196fd2-f3fa-4f08-8831-1a5af95fe2db cis
subaccount-admin        <null>    Allows management of resources in the subaccount in which the service instance of this plan was c... true      8c308b8a-6ec2-4ce6-b11f-a5f024d7fa8c 401522bd-666a-4748-82ef-8b2e4ca4113c service-manager
subaccount-audit        <null>    Allows read-only access to the resources in the subaccount in which the service instance was crea... true      c1ca03ff-a8a1-445a-b4c3-9d4d71249696 401522bd-666a-4748-82ef-8b2e4ca4113c service-manager
standard                <null>    Applications can use this plan to provide personal data related data privacy features.               true      e12690e5-6120-4dcd-8f71-0816ecc56a26 68ca5a29-8690-46b7-bb68-65916b5d408b personal-data-manager-service
shared                  <null>    This plan allows trial access to a shared ABAP system                                                true      7351af98-046f-4b72-b65d-1218a36e771c 014e319a-9568-44ab-ac42-1a4eba657b01 abap-trial
container               <null>    Allows management of service instances and bindings in a reduced scope. Instances created in a co... true      e2ca7af8-4658-4a9e-a555-35f424c259f5 401522bd-666a-4748-82ef-8b2e4ca4113c service-manager
connectivity_proxy      <null>    Pair Connectivity Proxy with SAP CP Connectivity service for establishing secure connections to o... true      28bab57d-d8dd-48b9-82f1-4ba5e354633f 3a50dc9c-0f77-4e32-82ee-3f36f115d13a connectivity
proxy                   <null>    Credential Store service proxy                                                                       true      1c0e1e42-b36f-470f-bc99-c2728ebd275d cfa21e04-a7ff-451e-9dbe-d48abf94c156 credstore
default                 <null>    Service plan ‘default’ for production usage of Document Information Extraction, charged in bl...     true      f2ee7f92-38ad-4b90-9db2-30d14241d017 071573de-bf5b-428e-ac83-d78f6a189779 document-information-extraction-trial
default                 <null>    [DEPRECATED] Default plan for Auditlog API                                                           true      a97d8970-7a14-48c4-acf2-9f49789f71b0 388c9db1-6eba-42f8-88c5-491e799ef15d auditlog-api
sap-integration         <null>    Service plan for SAP-to-SAP integrations (limited to 1 million requests per month and 50 GB of da... true      91caa825-dca6-4c05-819a-096b8ed228a6 73c2ec0e-ce88-4a9c-b079-8eebc8742671 one-mds
trial                   <null>    Credential Store service trial                                                                       true      3dc56bab-7192-4a21-9498-4412151f9f6f cfa21e04-a7ff-451e-9dbe-d48abf94c156 credstore
blocks_of_100           <null>    Service plan ‘blocks_of_100’ for production usage of Document Information Extraction, charged...     true      192b8ac9-5502-403b-9b56-30793dec5374 071573de-bf5b-428e-ac83-d78f6a189779 document-information-extraction-trial
reporting-ga-admin      <null>    Enables the generation of reports based on the resource and cost consumption of services and appl... true      fffd1a81-4d5e-4622-a614-5a1a931602fe 722e403b-6395-440d-bff6-e4028cb436b0 uas
service-operator-access <null>    Provides credentials for SAP BTP service operator to access SAP BTP from a Kubernetes cluster        true      1c469e56-f3ed-4321-959c-a890195362a1 401522bd-666a-4748-82ef-8b2e4ca4113c service-manager
trial                   <null>    Trial                                                                                                true      f27660c7-debd-492c-ab92-e7cdf4ff799b 5eabdf79-1bd2-4fe5-99c6-822eda67c45d ui5-flexibility-keyuser
standard                <null>    Default standard plan                                                                                true      88802dcb-7d7a-4b89-8c81-ff14254da893 6437452e-d930-435e-a263-71cfdd4ea0df data-attribute-recommendation-trial
standard                <null>    Standard Plan for Business Entity recognition Service                                                true      63b85684-5e43-4f75-92fb-f092f830b2d0 dad267e9-23a6-455f-bda4-6a51c4b800df business-entity-recognition-trial
blocks_of_100           <null>    Blocks of 100 plan for Service Ticket Intelligence                                                   true      50c83cbb-6890-4664-807b-8878c5b5f209 b6e5db8d-39d1-4456-b894-9ad0754472cc service-ticket-intelligence-trial
receiver                <null>    Establish the connection to print clients                                                            true      91209ea8-eeb7-475a-830f-9b631267fb36 e3a8638d-6d71-49cc-8a0a-fbfed3cd525e print
trial                   <null>    Trial service plan for Document Translation                                                          true      30e7af0f-d093-4bf4-acc6-58c548d9a207 119c15ab-7071-4a5d-9a55-16d32e8900cf document-translation

32 entries

OK

```

There's a lot of information here, but if you wanted a subset or a summary, you'd have to use a pipeline of text tools to get that. Moreover, while there's a lot of information here, there's actually more to be had, too much to display. 

The btp CLI offers JSON as an alternative output format. The advantage of JSON output is that it's more predictable, more easily parseable (with an appropriate JSON-focused tool), and it's easier to convey more information, simply in the form of more properties per object.

👉 Try the invocation again but this time use the `--format JSON` option as shown:

```bash
btp --format json list services/plan
```

You can see from the raw JSON output that there's more information, and it's in a structured format. 

Let's say you wanted to provide a CSV report which listed the service offerings, and the plans available for them, but you only wanted a list of those plans marked as "free". Something like this:

```csv
"abap-trial","shared"
"auditlog-api","default"
"auditlog-management","default"
"business-entity-recognition-trial","standard"
"cis","central,local"
"connectivity","connectivity_proxy"
"credstore","proxy,trial"
"data-attribute-recommendation-trial","standard"
"destination","lite"
"document-information-extraction-trial","default,blocks_of_100"
"document-translation","trial"
"feature-flags","lite"
"html5-apps-repo","app-host,app-runtime"
"one-mds","sap-integration"
"personal-data-manager-service","standard"
"print","receiver"
"saas-registry","application"
"service-manager","subaccount-admin,subaccount-audit,container,service-operator-access"
"service-ticket-intelligence-trial","blocks_of_100"
"transport","standard"
"uas","reporting-ga-admin"
"ui5-flexibility-keyuser","trial"
"xsuaa","application,broker"
```

In this CSV report, you can see for example that for the XSUAA service there are two free plans: application and broker.

In this section, you're going to write a filter to produce this output. The filter is a single line program written in jq, the [lightweight and flexible command-line JSON processor](https://stedolan.github.io/jq/).

#### Store the data locally

Start by storing the output in a local file. This has two small effects:

* each time you run the filter, you'll get the output immediately rather than have to wait for the `btp` to faciliate the call for you 
* you're being a good cloud citizen, reducing the actual number of API calls being made

👉 Run the btp CLI command as before but redirect the output to a file, like this:

```bash
btp --format json list services/plan > data.json
```

#### Get an overview of the plans

👉 See how many plans there are in total:

```bash
jq 'length' data.json
```

This will give you a JSON value like this:

```text
32
```

👉 List the plans, with the service that they relate to, and whether they're free or not:

```bash
jq '
  map([
    .service_offering_name,
    .catalog_name, 
    if .free then "free" else "not free" end
  ])
' data.json
```

This will produce output something like this (output here reduced for brevity):

```json
[
  [
    "xsuaa",
    "application",
    "free"
  ],
  [
    "xsuaa",
    "broker",
    "free"
  ],
  [
    "alert-notification",
    "standard",
    "not free"
  ],
  [
    "feature-flags",
    "lite",
    "free"
  ]
]
```

Now we've got a feeling for what data we need.

#### Filter out the non-free plans

Let's get rid of the non-free plans immediately so we can focus on the free ones.

👉 Run this filter:

```bash
jq '
  map(select(.free)) 
  | length
' data.json
```

If there were some non-free plans in your output, then the number produced from this will be less than the one you saw at the start of this section. In this sample data at the time of writing, there is one non-free plan, so the output from this is:

```text
31
```

#### Combine the filter and list 

We're building the filter up gradually. At this point you should continue by combining the previous two steps (the list and the filter):

👉 Combine them like this:

```bash
jq '
  map(select(.free))
  | map([
      .service_offering_name,
      .catalog_name
    ])
' data.json
```

> The keen amongst you might be wondering about the two consecutive calls to `map` and you'd be right. We did it like this first so you could see how two separate expressions could be combined (with the pipe operator `|`). We'll keep it simple like this, and avoid trying to [golf](https://code.golf/) the code, but if you're interested, here's one way of simplifying:
> ```bash
> jq '
>   map(
>     select(.free)
>     | [
>         .service_offering_name,
>         .catalog_name
>       ]
>   )
> ' data.json
> ```

#### Group by service

You'll have noted that each "record" represents a plan, and there can be more than one record for a given service (the XSUAA service is a good example, where there are the application and broker plans). 

We want one CSV record per service, with plans for the service listed together. So this is now a good time to realise that relationship.

👉 Add a `group_by` function to do this:

```bash
jq '
  map(select(.free))
  | map([
      .service_offering_name,
      .catalog_name
    ])
  | group_by(first)
' data.json
```

This will produce an array of arrays, with each inner array representing a single service offering, like this (again, output reduced for brevity):

```json
[
  [
    [
      "abap-trial",
      "shared"
    ]
  ],
  [
    [
      "credstore",
      "proxy"
    ],
    [
      "credstore",
      "trial"
    ]
  ],
  [
    [
      "xsuaa",
      "application"
    ],
    [
      "xsuaa",
      "broker"
    ]
  ]
]
```

Observe how each inner array itself contains one or more arrays, one per plan; in this sample output, the `abap-trial` service offering has one plan, and the `credstore` and `xsuaa` service offerings each have two plans.

#### Transform the array of arrays into a simpler list

Now we have the data that we want in a structure that almost represents what we need, it's time to transform that into a simpler list.

👉 Add a final `map` like this:

```bash
jq '
     map(select(.free))
    | map([
        .service_offering_name,
        .catalog_name
      ])
    | group_by(first)
    | map([
        (.[0] | .[0]),
        (map(.[1]) | join(","))
      ])
' data.json
```

This will produce something like this (as before, output reduced for brevity):

```json
[
  [
    "abap-trial",
    "shared"
  ],
  [
    "cis",
    "central,local"
  ],
  [
    "xsuaa",
    "application,broker"
  ]
]
```

Before moving on, it's worth taking a moment to understand this new addition to the pipeline, with those slightly mysterious looking array indices `.[0]` and `.[1]`. 

Consider a single subarray, that this final `map` will be iterating over. Let's take the XSUAA one, which looks like this (shown here with the same indentation as it appears with above, for consistency, and to emphasize that it's a subarray, within an outer `[ ... ]` array):

```json
  [
    [
      "xsuaa",
      "application"
    ],
    [
      "xsuaa",
      "broker"
    ]
  ]
```

Each iteration of the `map` call gets to process a JSON value (this entire subarray) like this. And what we're looking for is:

* a single instance of the service offering name (`xsuaa`)
* plus a list of the (one or more) plan names (`application` and `broker`)

Like this:

```json
  [
    "xsuaa",
    "application,broker"
  ]
```

In order to achieve this, we must first pick out the service name, as the value of the first item of the first subarray within this XSUAA service subarray, i.e. this one:

```text
                                            +------------------------------------+
XSUAA service subarray     ---------> [     |                                    |
first subarray within that    ------>   [   V              -+          (.[0] | .[0])
first item in that first subarray -->     "xsuaa",          |             |
                                          "application"     | <-----------+
                                        ],                 -+
                                        [
                                          "xsuaa",
                                          "broker"
                                        ]
                                      ]
```

This is done with `(.[0] | .[0])` ("the first item of the first item"). We choose the first one, because why not, and because there won't be a second or subsequent one if there's only one plan.

For the plan names, we want a list of the second items of all the subarrays within the XSUAA subarray, i.e.:

```text
                                      [
                                        [              
                                          "xsuaa",
                                          "application"  <--- this one
                                        ],
                                        [
                                          "xsuaa",
                                          "broker"       <--- and this one
                                        ]
                                      ]
```

Once picked out, the values in the list of them are joined with a comma.

This is done with the `(map(.[1]) | join(","))` expression.

This final `map` thus produces output that we saw just now, i.e. an array of arrays, with one inner array per service, and the inner array elements being the service name and a list of plan names:

```json
[
  [
    "abap-trial",
    "shared"
  ],
  [
    "cis",
    "central,local"
  ],
  [
    "xsuaa",
    "application,broker"
  ]
]
```

#### Create CSV output

Now we have the data we want, and pretty much in a format from which we can create CSV records.

👉 Start to do that now, by adding the first part of this final stage, like this:

```bash
jq '
     map(select(.free))
    | map([
        .service_offering_name,
        .catalog_name
      ])
    | group_by(first)
    | map([
        (.[0] | .[0]),
        (map(.[1]) | join(","))
      ])
    | .[]
' data.json
```

Piping the previous output (an array of arrays) through `.[]` effectively "explodes" those subarrays and outputs them one at a time, passing them through any further filters. The output changes subtly from a single JSON value which is an array of arrays, to multiple JSON values, each of which are the individual arrays:

```json
[
  "abap-trial",
  "shared"
],
[
  "cis",
  "central,local"
],
[
  "xsuaa",
  "application,broker"
]
```

This change allows us to pass each of these JSON values through the `@csv` format string. 

👉 Do that now, and also include the `--raw-output` (or `-r`) option to tell `jq` not to try to output JSON values (each entire CSV record would be output enclosed in double quotes, so that they're valid JSON, but we don't want that here):

```bash
jq --raw-output '
     map(select(.free))
    | map([
        .service_offering_name,
        .catalog_name
      ])
    | group_by(first)
    | map([
        (.[0] | .[0]),
        (map(.[1]) | join(","))
      ])
    | .[]
    | @csv
' data.json
```

Effectively, each of the arrays that look like this:

```json
[
  "xsuaa",
  "application,broker"
]
```

get properly and reliably formatted as CSV records. This one above is output like this:

```csv
"xsuaa","application,broker"
```

So the final result of this program reads the original JSON output from the `btp --format json list services/plan` call, and produces this:

```csv
"abap-trial","shared"
"auditlog-api","default"
"auditlog-management","default"
"business-entity-recognition-trial","standard"
"cis","central,local"
"connectivity","connectivity_proxy"
"credstore","proxy,trial"
"data-attribute-recommendation-trial","standard"
"destination","lite"
"document-information-extraction-trial","default,blocks_of_100"
"document-translation","trial"
"feature-flags","lite"
"html5-apps-repo","app-host,app-runtime"
"one-mds","sap-integration"
"personal-data-manager-service","standard"
"print","receiver"
"saas-registry","application"
"service-manager","subaccount-admin,subaccount-audit,container,service-operator-access"
"service-ticket-intelligence-trial","blocks_of_100"
"transport","standard"
"uas","reporting-ga-admin"
"ui5-flexibility-keyuser","trial"
"xsuaa","application,broker"
```

Job done!
