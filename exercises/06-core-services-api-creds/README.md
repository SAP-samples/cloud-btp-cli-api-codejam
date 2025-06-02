# Exercise 06 - Gathering required credentials for the API call

Having determined that we want to make an API call to the singular endpoint in the Regions for Global Account group, i.e. to:

```text
/entitlements/v1/globalAccountAllowedDataCenters
```

we learned in the previous exercise that we needed an instance of the SAP Cloud Management service, and chose the `central` plan to do that with. Given that we intend to create that instance in our Cloud Foundry (CF) environment instance in our subaccount, we spent the rest of the exercise learning how to mine and extract relevant information from the rich seam of SAP BTP resource data that is available to us via the JSON output format with the btp CLI.

Specifically, we worked out how to find, mechanically, the API endpoint that we need to login with the CF CLI `cf`.

In this exercise we'll use that, log in with `cf` and go on to work through the rest of the boxes in this diagram here:

```text
+----------------+      +----------------+      +----------------+
|    Service     |      |    Instance    |      |    Binding     |
|      cis       |--+-->|                |----->|                |
|                |  |   |                |      |                |
+----------------+  |   +----------------+      +----------------+
        |           |                                   |
        |           |                                   |
        |           |                                   |
+----------------+  |                                   |
|      Plan      |  |                                   |
|     central    |--+                                   |
|                |                                      |
+----------------+                                      |
                                                        |
        +-----------------------------------------------+
        |
        V
+----------------+      +----------------+
|     Token      |      |    API Call    |
|                |----->|                |
|                |      |                |
+----------------+      +----------------+
```

We will stop just before the "API Call" box, and do that in the subsequent exercise.

## Log in with the CF CLI

With the API endpoint now obtained, we can log in with the CF CLI. You could do it like this, specifying the actual API endpoint URL with the `-a` option and copy-pasting the URL from the output above:

```bash
cf login -a <API endpoint URL>
```

However, it's much easier to use the power of the shell to do this in one go, as follows.

👉 Ensure you're in the directory containing this exercise's `README.md` file, and make this call (replacing `trial` with the name of your subaccount):

```bash
cd $HOME/projects/cloud-btp-cli-api-codejam/exercises/06-core-services-api-creds
cf login -a $(./get-cf-api-endpoint "trial")
```

> Just like in the previous exercise, the `get-cf-api-endpoint` in this directory is [just a symbolic link](get-cf-api-endpoint) to the [real script](../../scripts/get-cf-api-endpoint) in the shared [scripts/](../../scripts/) directory.

Supply your BTP trial account credentials (email address and password). Here's what the flow will look like:

```text
user: 06-core-services-api-creds $ cf login -a $(./get-cf-api-endpoint "trial")
API endpoint: https://api.cf.us10-001.hana.ondemand.com

Email: dj.adams@sap.com
Password:

Authenticating...
OK

Targeted org 013e7c57trial.

Targeted space dev.

API endpoint:   https://api.cf.us10-001.hana.ondemand.com
API version:    3.193.0
user:           dj.adams@sap.com
org:            013e7c57trial
space:          dev
```

> You should already have a space set up, as described in the [Subaccount and Cloud Foundry environment](../../prerequisites.md#subaccount-and-cloud-foundry-environment) section of the prerequisites.

Just like the btp CLI, the CF CLI also has an option to allow you to use SSO to sign in. If you want, try this approach:

```bash
cf login -a $(./get-cf-api-endpoint "trial") --sso
```

You should be given a URL to navigate to, authenticate, and receive a code to paste in at the prompt, and it should look something like this:

```text
user: 06-core-services-api-creds $ cf login -a $(./get-cf-api-endpoint "trial") --sso
API endpoint: https://api.cf.eu10.hana.ondemand.com

Temporary Authentication Code ( Get one at https://login.cf.eu10.hana.ondemand.com/passcode ):
Authenticating...
OK

...
```

## Create a service instance and key

👉 Now you're authenticated, create an instance of the Cloud Management Service, with the "central" plan, as discussed earlier:

> If you already have an instance of this service, you may need to remove it so that you can create this one.

```bash
cf create-service cis central cis-central
```

The output should look something like this:

```text
Creating service instance cis-central in org 8fe7efd4trial / space dev as dj.adams@sap.com...
OK
```

👉 For this new instance, create a service key:

```bash
cf create-service-key cis-central cis-central-sk
```

The output should look something like this:

```text
Creating service key cis-central-sk for service instance cis-central as dj.adams@sap.com...
OK
```

> The naming convention used here for instance and service key resources has instances named after a combination of service name and plan name (`cis-central`) and a service key named similarly, suffixed with `-sk` here (`cis-central-sk`). You may have your own naming conventions in your organization, but we'll stick to this one for this CodeJam content.

At this point, we can update our diagram with the two new entity names in the `Instance` and `Binding` (service key) boxes:

```text
+----------------+      +----------------+      +----------------+
|    Service     |      |    Instance    |      |    Binding     |
|      cis       |--+-->|   cis-central  |----->| cis-central-sk |
|                |  |   |                |      |                |
+----------------+  |   +----------------+      +----------------+
        |           |                                   |
        |           |                                   |
        |           |                                   |
+----------------+  |                                   |
|      Plan      |  |                                   |
|     central    |--+                                   |
|                |                                      |
+----------------+                                      |
                                                        |
        +-----------------------------------------------+
        |
        V
+----------------+      +----------------+
|     Token      |      |    API Call    |
|                |----->|                |
|                |      |                |
+----------------+      +----------------+
```

> We're deliberately interchanging the terms "binding" and "service key" so that they become related in our minds.

## Take a first look at the service key

What's in a service key? Let's take a first look, via `cf`.

👉 Use the following command to examine the contents of the service key (there are some long strings of characters that represent credentials in some service keys, including this one, so take care when displaying the content on the screen):

```bash
cf service-key cis-central cis-central-sk
```

The output should look something like this:

```text
Getting key cis-central-sk for service instance cis-central as dj.adams@sap.com...

{
  "credentials": {
    "endpoints": {
      "accounts_service_url": "https://accounts-service.cfapps.eu10.hana.ondemand.com",
      "cloud_automation_url": "https://cp-formations.cfapps.eu10.hana.ondemand.com",
      "entitlements_service_url": "https://entitlements-service.cfapps.eu10.hana.ondemand.com",
      "events_service_url": "https://events-service.cfapps.eu10.hana.ondemand.com",
      "external_provider_registry_url": "https://external-provider-registry.cfapps.eu10.hana.ondemand.com",
      "metadata_service_url": "https://metadata-service.cfapps.eu10.hana.ondemand.com",
      "order_processing_url": "https://order-processing.cfapps.eu10.hana.ondemand.com",
      "provisioning_service_url": "https://provisioning-service.cfapps.eu10.hana.ondemand.com",
      "saas_registry_service_url": "https://saas-manager.cfapps.eu10.hana.ondemand.com"
    },
    "grant_type": "user_token",
    "sap.cloud.service": "com.sap.core.commercial.service.central",
    "uaa": {
      "apiurl": "https://api.authentication.eu10.hana.ondemand.com",
      "clientid": "sb-ut-f2184e34-95a2-4c72-ba64-46aaf9d7d4f7-clone!b169670|cis-central!b14",
      "clientsecret": "7c2b411f-8949-4ce1-ac0b-66dabda938a6$tytFAKxV0J7PX4UV6cngOv9mqnSqwRUHEd4qVHTThZs=",
      "credential-type": "binding-secret",
      "identityzone": "65137137trial-ga",
      "identityzoneid": "06de8b78-0e1d-48a5-9323-97824c99671f",
      "sburl": "https://internal-xsuaa.authentication.eu10.hana.ondemand.com",
      "subaccountid": "06de8b78-0e1d-48a5-9323-97824c99671f",
      "tenantid": "06de8b78-0e1d-48a5-9323-97824c99671f",
      "tenantmode": "shared",
      "uaadomain": "authentication.eu10.hana.ondemand.com",
      "url": "https://65137137trial-ga.authentication.eu10.hana.ondemand.com",
      "verificationkey": "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApPKDGC55buMxdfi60gGx\n1WBIf1NI8K4TnOBAEGYDeL6BVVkyjvlKVznsWblcbOkOWYRILE5IKh0ngLFfhL7x\nUn5R7gMprXMPbgnUlKGiH7ohLqnrN0VWxCNKu87WRke3kGvbsmYHS28lBPouzSzf\ndyJ9umtDPZGAWdy7cFKbVXkZG7fHgowLuWaisXQRkAqdH564DWiRMqQ0GJiKXyrz\ncwafHDInN8Dit6eXye9yGAdEyln9oHVjSJxP/Nughof70W7UDSeKHuL46iJMecjd\nqajlWi1/KQzdynHwchNtHka1bR+wwNDJkCswyf5pKuMZQF8VR3dLRWi0iuqsLK/F\nvQIDAQAB\n-----END PUBLIC KEY-----",
      "xsappname": "ut-f2184e34-95a2-4c72-ba64-46aaf9d7d4f7-clone!b169670|cis-central!b14",
      "xsmasterappname": "cis-central!b14",
      "zoneid": "06de8b78-0e1d-48a5-9323-97824c99671f"
    }
  }
}
```

The next thing to do is to save this content to a file. First, so we don't need to keep calling `cf service-key`, but mostly so we can parse information out of it, because that's easy with `jq`, because the output is JSON, right?

Well, not quite.

The eagle-eyed amongst you will have spotted there's some extra output from `cf service-key` that we need to get rid of first before redirecting the rest of it to a file. And that's the first two "helpful" lines (in case you're wondering, the second line is a blank line):

```text
Getting key cis-central-sk for service instance cis-central as dj.adams@sap.com...

```

So we need to pass the output through something so we can remove these lines.

> Some CF proponents would at this stage point to specific access to the API endpoint facility afforded by the `cf curl` command, as described in [curl - Cloud Foundry CLI Reference Guide](https://cli.cloudfoundry.org/en-US/v7/curl.html). However, to have a separate, incompatible set of objects and API shapes, just to be able to have a cleaner output on the command line, is contrary to the Unix Philosophy and is not an ideal alternative for ad hoc contexts such as this.

To make the cleanup, the venerable [sed](https://www.gnu.org/software/sed/manual/sed.html) will do nicely (we did use it briefly in a previous exercise when [setting up autocomplete](../03-autocomplete-and-exploration#set-up-autocomplete)).

👉 Re-run the previous `cf` command, but this time, pipe the output into `sed`, specifying a short script to delete lines 1 and 2, and then redirect the output of that into a file `cis-central-sk.json`:

```bash
cf service-key cis-central cis-central-sk | sed '1,2d' > cis-central-sk.json
```

You can check the file contains just the JSON by asking `jq` to print it out nicely:

👉 Try that now:

```bash
jq . cis-central-sk.json
```

You should see a nicely formatted display of JSON. Note that depending on the version of `cf` you're using, the structure of the JSON emitted from this `cf` command [may be different](https://github.com/SAP-samples/cloud-btp-cli-api-codejam/issues/27#issuecomment-1370702907). Don't worry, in this CodeJam, whether you're using a container or a Dev Space in SAP Business Application Studio, you'll be using version 8 consistently, and the scripts are ready for that.

> Technically speaking, the `.` in `jq` is the [identity](http://jqlang.github.io/jq/manual/#identity) filter, so the nice formatting of the JSON is actually just a by-product of asking `jq` to filter the JSON through the identity filter (which just produces whatever it receives), and by default `jq` will endeavour to pretty-print the output.
> Note also that this time, the `.` is not in single quotes, unlike when you last used this filter in a previous exercise, when [Listing the available datacenter names](../04-retrieving-parsing-json-output#listing-the-available-datacenter-names). It isn't absolutely necessary, so we're omitting it in this instance (and we'll make a similar change later in this exercise when we use the `keys` filter too).

Values in this JSON data are needed to:

* request an authorization token (with the `clientid`, `clientsecret` and `url` properties in the `uaa` object)
* make the actual API call (with the `entitlements_service_url` property in the `endpoints` object)

Background details on this are available in the SAP Help Portal page linked in the [Further reading](#further-reading) section below.

## Request the token

Now you can request the token. It's essentially an HTTP request to an OAuth 2.0 endpoint with parameters supplying the grant type, username and password details, and authentication in the form of the `clientid` and `clientsecret` values above.

In this directory, there's a link to a script called [generate-password-grant-type](../../scripts/generate-password-grant-type) that you can run, and at the heart is this `curl` invocation, which gives you an idea of what's going to happen:

```bash
curl \
  --url "$uaa_url/oauth/token" \
  --user "$clientid:$clientsecret" \
  --data 'grant_type=password' \
  --data-urlencode "username=$email" \
  --data-urlencode "password=$password"
```

You're going to run that script now.

👉 First, make sure you're still in this exercise's directory:

```bash
cd $HOME/projects/cloud-btp-cli-api-codejam/exercises/06-core-services-api-creds/
```

👉 Now invoke the script, specifying the name of the file containing the service key JSON data:

```bash
./generate-password-grant-type cis-central-sk.json
```

You'll be asked to authenticate, and you must specify your SAP BTP email and password. If the call is successful, you'll see some JSON output. A good sign! But it's more or less unreadable just output to the terminal in raw form.

👉 So repeat the invocation and save the output to a file; then you can pick out details with `jq`:

```bash
./generate-password-grant-type cis-central-sk.json > tokendata.json
```

> You can of course simply open the file in your Dev Space editor, but where's the fun in that? Also, if you do, it will most likely be displayed as one, long, unreadable line.

👉 Have a look what properties there are in this JSON:

```bash
jq keys tokendata.json
```

You should see some output like this:

```json
[
  "access_token",
  "expires_in",
  "id_token",
  "jti",
  "refresh_token",
  "scope",
  "token_type"
]
```

These properties look like the right ones - we have an access token that we can now use to authenticate the API call, and we even have a refresh token to ask for a new one when the current one expires.

> See the reference to the "keys" section of the `jq` manual in the [Further reading](#further-reading) section below to read more on the "keys" function.

Now we can update our diagram to record the fact that we now have a token!

```text
+----------------+      +----------------+      +----------------+
|    Service     |      |    Instance    |      |    Binding     |
|      cis       |--+-->|   cis-central  |----->| cis-central-sk |
|                |  |   |                |      |                |
+----------------+  |   +----------------+      +----------------+
        |           |                                   |
        |           |                                   |
        |           |                                   |
+----------------+  |                                   |
|      Plan      |  |                                   |
|     central    |--+                                   |
|                |                                      |
+----------------+                                      |
                                                        |
        +-----------------------------------------------+
        |
        V
+----------------+      +----------------+
|     Token      |      |    API Call    |
|  access_token  |----->|                |
|                |      |                |
+----------------+      +----------------+
```

### Understand the HTTP call

Now that you've successfully made an OAuth 2.0 call to request an access token, you can relax a bit. But not completely - it's important that you understand what just happened. The [generate-password-grant-type](../../scripts/generate-password-grant-type) script wrapped the call for you, so to finish this exercise, let's unwrap it a bit and make sure we know what the `curl` invocation is doing.

We'll cover the answers to all the questions in this section in a short discussion, when we get to the end of this exercise.

👉 Open the `generate-password-grant-type` script in the editor and stare at the `curl` invocation, and in particular each parameter. Have a think about these questions:

* Where does the `$uaa_url` variable come from, and what does it represent?
* What's the `/oauth/token` suffix for?
* What's going on with the `--user` option?
* Why is `--data` sometimes used, and other times `--data-urlencode`?
* What HTTP request method is used in this call?
* What should be the Content Type sent along with the request?

👉 Modify the `generate-password-grant-type` script by adding a `--verbose` option to the `curl` invocation. If you're using a Dev Space, just open the file up through the Explorer - but remember, the source is in the [scripts/](../../scripts/) directory, there's only a [symbolic link](generate-password-grant-type) in [this](.) directory). If you're using a container, you have a couple of options. If you're feeling hardcore, you can of course use The One True Editor (`vim`). Alternatively, you can use `nano` (like this: `nano generate-password-grant-type`). However you edit, the `curl` invocation should end up looking like this (don't forget the `\` to escape the newline):

```bash
curl \
  --verbose \
  --url "$uaa_url/oauth/token" \
  --user "$clientid:$clientsecret" \
  --data-urlencode 'grant_type=password' \
  --data-urlencode "username=$email" \
  --data-urlencode "password=$password"
```

👉 Run the script again, in the same way:

```bash
./generate-password-grant-type cis-central-sk.json > tokendata.json
```

You should now see lots of output telling you what's happening.

👉 Take a few moments to stare at this too, and think about these additional questions:

* What was the HTTP status code in the response?
* Did you work out what the Content Type of the request should be, and did you get it correct?
* What happened to the `clientid` and `clientsecret` values supplied via the `--user` option?
* What was the Content Type of the response?

## Summary

You now know how to get a service key (binding) via an instance of a service on SAP BTP, specifically in the CF environment. You also know now what sort of information this service key contains and how you can use it in an OAuth 2.0 flow to request an access token. You're now ready to use the access token to make the API call in the next exercise!

## Further reading

* [Understanding OAuth 2.0 grant types](https://github.com/SAP-archive/cloud-apis-virtual-event/tree/main/exercises/02#3-understand-oauth-20-grant-types)
* [Getting an Access Token for SAP Cloud Management Service APIs](https://help.sap.com/docs/btp/sap-business-technology-platform/getting-access-token-for-sap-cloud-management-service-apis)
* [The builtin keys and keys_unsorted functions in jq](https://jqlang.org/manual/#keys-keys_unsorted)
* Hands-on SAP Dev episode: [Back to basics: Using curl in the SAP enterprise landscape](https://www.youtube.com/watch?v=k34-lD77Aj4)

---

## Questions

If you finish earlier than your fellow participants, you might like to ponder these questions. There isn't always a single correct answer and there are no prizes - they're just to give you something else to think about.

1. What other naming conventions for Cloud Foundry instances and service keys have you seen? Are there ones you prefer to use, and if so, what are they?
1. We used `sed` to strip off the unwanted first two lines of the service key output. How else might we have done this?
1. Take a look at the token data you retrieved - what's the lifetime of the access token, in hours?
1. Did you manage to think about the questions on the `curl` invocation details?

---

[Next exercise](../07-core-services-api-call/README.md)
