# Exercise 04 - JSON output format and APIs

At the end of this exercise, you'll know how to get the btp CLI to give you a more predictable and machine-readable output, which is especially helpful for combining the use of the btp CLI into automation and other scripts. You'll also have an insight into how the [Core Services for SAP BTP](https://api.sap.com/package/SAPCloudPlatformCoreServices/rest) API package is aligned with what you can retrieve with `btp` commands.

This exercise makes use of some scripts which are in this repository, so as an exercise-specific prerequisite, you should clone this repository into your Dev Space.

👉 Do this now by following [the instructions](clone-this-repo.md), and then come back to this README.

## List the available regions

Within the "accounts" group, there's an "available-region" object that can be listed.

👉 Use the power of autocomplete that you set up in [Exercise 03](../03-autocomplete-and-exploration/README.md) to invoke this:

```bash
btp list accounts/available-region
```

The output should look something like this:

```

Showing available regions for global account fdce9323-d6e6-42e6-8df0-5e501c90a2be:

region   data center   environment    provider
ap21     cf-ap21       cloudfoundry   AZURE
us10     cf-us10       cloudfoundry   AWS
eu10     cf-eu10       cloudfoundry   AWS


OK
```

## Parsing the output

Traditional Unix commands output only the data requested, often with no frills. What you might want if you were intending to write a script to examine the possible regions and make a decision based upon what was available, is just the basic output:

```
ap21     cf-ap21       cloudfoundry   AZURE
us10     cf-us10       cloudfoundry   AWS
eu10     cf-eu10       cloudfoundry   AWS
```

This is more akin to the Unix philosophy; what's more, the separation between the columns of output would likely be done via tab characters which are more readily parsed (especially by tools such as [cut](https://man7.org/linux/man-pages/man1/cut.1.html) which expect tab as the default separator) and are less likely to be part of the data columns.

There are many ways with the traditional Unix approach to trim the extra output from this btp CLI invocation, in order to reduce it to the basics. Here are two examples.

The first uses [sed](https://en.wikipedia.org/wiki/Sed):

```
user: user $ btp list accounts/available-region 2> /dev/null | sed '1,/^region /d; /^$/d'
ap21     cf-ap21       cloudfoundry   AZURE
us10     cf-us10       cloudfoundry   AWS
eu10     cf-eu10       cloudfoundry   AWS
user: user $
```

The second uses [grep](https://en.wikipedia.org/wiki/Grep):

```
user: user $ btp list accounts/available-region 2> /dev/null | grep -E '^[a-z]{2}[0-9]{2}\s+'
ap21     cf-ap21       cloudfoundry   AZURE
us10     cf-us10       cloudfoundry   AWS
eu10     cf-eu10       cloudfoundry   AWS
user: user $
```

> The redirection of STDERR to `/dev/null` in both of these examples is to get rid of the "OK" part of the result which is currently emitted to that error file descriptor.

These and many more approaches do the job, but they are somewhat brittle and depend on the data and the output. The challenge with each of the above two (deliberately simple) approaches are:

* the `sed` based solution relies on the "region" heading
* the `grep` based solution assumes the region identifiers are two lowercase letters followed by two digits

## Use the JSON format output option

Some more recent command line tools deal with resources that are structured in ways that are sometimes too complex to be represented in plain text. The [JSON](https://en.wikipedia.org/wiki/JSON) format is commonly used to express more structured data, and is often used as an alternative output format for commands.

JSON output is a more convenient way to convey structure, and can be parsed more reliably. JSON output from the btp CLI, via the `--format json` option, is more predictable and the team's aim is to keep it as stable as possible.

👉 Rerun the previous btp CLI command but this time use the `--format json` option:

```bash
btp --format json list accounts/available-region
```

You should see something like this:

```json
{
  "datacenters": [
    {
      "name": "cf-ap21",
      "displayName": "Singapore - Azure",
      "region": "ap21",
      "environment": "cloudfoundry",
      "iaasProvider": "AZURE",
      "supportsTrial": true,
      "provisioningServiceUrl": "https://provisioning-service.cfapps.ap21.hana.ondemand.com",
      "saasRegistryServiceUrl": "https://saas-manager.cfapps.ap21.hana.ondemand.com",
      "domain": "ap21.hana.ondemand.com",
      "geoAccess": "BACKWARD_COMPLIANT_EU_ACCESS"
    },
    {
      "name": "cf-us10",
      "displayName": "US East (VA) - AWS",
      "region": "us10",
      "environment": "cloudfoundry",
      "iaasProvider": "AWS",
      "supportsTrial": true,
      "provisioningServiceUrl": "https://provisioning-service.cfapps.us10.hana.ondemand.com",
      "saasRegistryServiceUrl": "https://saas-manager.cfapps.us10.hana.ondemand.com",
      "domain": "us10.hana.ondemand.com",
      "geoAccess": "BACKWARD_COMPLIANT_EU_ACCESS"
    },
    {
      "name": "cf-eu10",
      "displayName": "Europe (Frankfurt) - AWS",
      "region": "eu10",
      "environment": "cloudfoundry",
      "iaasProvider": "AWS",
      "supportsTrial": false,
      "provisioningServiceUrl": "https://provisioning-service.cfapps.eu10.hana.ondemand.com",
      "saasRegistryServiceUrl": "https://saas-manager.cfapps.eu10.hana.ondemand.com",
      "domain": "eu10.hana.ondemand.com",
      "geoAccess": "BACKWARD_COMPLIANT_EU_ACCESS"
    }
  ]
}
```

> You'll also see an empty line and then an "OK" but this is again sent to STDERR. From now on the executable examples will include redirecting STDERR to `/dev/null` to avoid the empty line and "OK" - but bear in mind this is an extreme workaround because it would prevent any real errors from being displayed. See ticket [CPCLI-615](https://jtrack.wdf.sap.corp/browse/CPCLI-615) for a discussion on this.

Parsing JSON with the right tool is straightforward and very powerful. One tool that is popular for this is [jq](https://stedolan.github.io/jq/), which is described as "a lightweight and flexible command-line JSON processor". It supports an entire language [which is Turing complete](https://github.com/MakeNowJust/bf.jq) but is readily useful at a simple level too. Your App Studio Dev Space comes already equipped with `jq` so you can try it out now.

👉 Repeat the previous command, but this time pipe the output into `jq`, giving it a simple expression to list the names of the data centers:

```bash
btp --format json list accounts/available-region 2> /dev/null \
    | jq '.datacenters[].displayName'
```

This should produce output like this:

```
"Singapore - Azure"
"US East (VA) - AWS"
"Europe (Frankfurt) - AWS"
```

> `jq` always endeavors to produce JSON output - here, three valid JSON values are emitted (a double-quoted string is a valid JSON value). You can use the `-r` option to tell `jq` to emit raw strings if you want to avoid the double quotes.

## Call the corresponding Entitlement Service API

The btp CLI implementation has a client / server nature. The server component facilitates calls to APIs in the [Core Services for SAP BTP](https://api.sap.com/package/SAPCloudPlatformCoreServices/rest) package. So the btp CLI effectively gives you a comfortable way of consuming those APIs that are specifically designed to let you "manage, build, and extend the core capabilities of SAP BTP".

In this part of this exercise you'll see that first hand, by observing that the JSON emitted from `btp --format json list accounts/available-region` is effectively the same as the output from a call to the corresponding API. The API endpoint in question lives within the [Entitlements Service](https://api.sap.com/api/APIEntitlementsService/overview) - in the [API Reference](https://api.sap.com/api/APIEntitlementsService/resource) section it's the "Regions for Global Account" endpoint:

![Regions for Global Account endpoint](assets/regions-for-global-account.png)

### Obtain an authorization token

The API endpoints are protected; the endpoints in the Entitlement Service are protected by the OAuth "Resource Owner Password Credentials" grant type, otherwise known as the "Password" grant type. This grant type is considered legacy, but is still used to protect some resources in this area. See the link to understanding OAuth 2.0 grant types in the [Further reading](#further-reading) section below for more background information.

Credentials to obtain an authorization token via the OAuth 2.0 password grant type process can be obtained from a service key relating to an instance of the [Cloud Management Service](https://help.sap.com/products/BTP/65de2977205c403bbc107264b8eccf4b/17b6a171552544a6804f12ea83112a3f.html?locale=en-US&version=Cloud), specifically with the "central" plan, a plan for using Cloud Management service APIs to manage your global accounts, subaccounts, directories, and entitlements.

So in this part you are going to create an instance of the Cloud Management Service (technical name "cis") with plan "central". Where? Well there are different places, but as the trial account that you're using already has a Cloud Foundry (CF) environment instance set up, we'll use that.

> This exercise relies on the fact that you do have a CF environment already set up in your "trial" subaccount; if you don't, but have one somewhere else in your trial global account, you may be able to use that instead.

#### Determine your CF API endpoint

First, in a similar way to how we logged in with the btp CLI, we now must log in with the CF CLI, `cf`. To do this we need to know which endpoint we must connect to, which we will do, shortly, like this:

```bash
cf login -a <API endpoint URL>
```

To discover what the endpoint URL is, you can just look in the BTP Cockpit:

![API endpoint visible in the BTP cockpit](assets/api-endpoint-in-cockpit.png)

But this is all about hands-on on the command line, and if we're going to be automating things, looking in the cockpit is not going to work for us. So let's determine the API endpoint in a different way, using the btp CLI to discover what it is.

In the [directory containing this specific README file](./), there's a script [get_cf_api_endpoint](./get_cf_api_endpoint). We'll examine how this script works in a later exercise, but if you were to glance at it, you'd see calls to the btp CLI:

* `btp --format json list accounts/subaccount`
* `btp --format json list accounts/environment-instance`

Information returned from these calls includes the CF API endpoint, amongst other CF details.

👉 After ensuring that you're still authenticated with the btp CLI (with `btp login`), run the script. It's a good idea at this stage to move to the directory containing it, and run it there, mostly because you'll be running another script in this same directory later:

```bash
cd $HOME/projects/HO060/exercises/04-json-format-and-apis
./get_cf_api_endpoint
```

It should emit the API endpoint URL; you should see something like this:

```
user: 04-json-format-and-apis $ ./get_cf_api_endpoint
https://api.cf.eu10.hana.ondemand.com
user: 04-json-format-and-apis $
```

#### Log in with the CF CLI

Now you can log in with the CF CLI. You could do it like this, specifying the actual API endpoint URL with the `-a` option and copy-pasting the URL from the output above:

```bash
cf login -a <API endpoint URL>
```

However, it's much easier to use the power of the shell to do this in one go, as follows.

👉 Assuming you're in the directory containing the `get_cf_api_endpoint` script, do this:

```bash
cf login -a $(./get_cf_api_endpoint)
```

Supply your BTP trial account credentials (email address and password). Here's what the flow will look like (this example based on being in this exercise's directory):

```
user: 04-json-format-and-apis $ cf login -a $(./get_cf_api_endpoint)
API endpoint: https://api.cf.eu10.hana.ondemand.com

Email: qmacro+blue@gmail.com
Password:

Authenticating...
OK

Targeted org 8fe7efd4trial.

Targeted space dev.

API endpoint:   https://api.cf.eu10.hana.ondemand.com
API version:    3.109.0
user:           qmacro+blue@gmail.com
org:            8fe7efd4trial
space:          dev
user: 04-json-format-and-apis $
```

#### Create a service instance and key

👉 Now you're authenticated, create an instance of the Cloud Management Service, with the "central" plan, as discussed earlier:

> If you already have an instance of this service, you may need to remove it so that you can create this one.

```bash
cf create-service cis central cis-central
```

The output should look something like this:

```
Creating service instance cis-central in org 8fe7efd4trial / space dev as qmacro+blue@gmail.com...
OK
```

> In a trial BTP account, not only is a Cloud Foundry environment instance set up for you automatically, but also an organization and space.

👉 For this new instance, create a service key:

```bash
cf create-service-key cis-central cis-central-sk
```

The output should look something like this:

```
Creating service key cis-central-sk for service instance cis-central as qmacro+blue@gmail.com...
OK
```

> The naming convention used here for instance and service key resources has instances named after a combination of service name and plan name (`cis-central`) and a service key named similarly, suffixed with `-sk` here (`cis-central-sk`).

#### Save the service key details

Now you have a service key, obtain the details (in JSON) and save them into a file locally (you'll see how to do this shortly).

Unfortunately, the `cf` command emits extraneous text output, a problem which is exacerbated by the fact that the main output is not text, but JSON. This is what it looks like:

```
Getting key cis-central-sk for service instance cis-central as qmacro+blue@gmail.com...

{
  "endpoints": {
   "accounts_service_url": "https://accounts-service.cfapps.eu10.hana.ondemand.com",
   "cloud_automation_url": "https://cp-formations.cfapps.eu10.hana.ondemand.com",
  ...
```

So a little bit of cleaning up is necessary before saving the service key details to a JSON file.

> Some CF proponents would at this stage point to specific access to the API endpoint facility afforded by the `cf curl` command, as described in [curl - Cloud Foundry CLI Reference Guide](https://cli.cloudfoundry.org/en-US/v7/curl.html). However, to have a separate, incompatible set of objects and API shapes, just to be able to have a cleaner output on the command line, is contrary to the Unix Philosophy and is not an ideal alternative for ad hoc contexts such as this.

👉 While still in this exercise's directory (where you are already), run this:

```bash
cf service-key cis-central cis-central-sk | sed '1,2d' > cis-central-sk.json
```

You can check the file contains just the JSON by asking `jq` to print it.

👉 Try that now:

```bash
jq . cis-central-sk.json
```

You should see a nicely formatted display of JSON. A cut down version of that JSON (with some of the properties removed, for brevity) looks like this:

```json
{
  "endpoints": {
    "cloud_automation_url": "https://cp-formations.cfapps.eu10.hana.ondemand.com",
    "entitlements_service_url": "https://entitlements-service.cfapps.eu10.hana.ondemand.com",
    "...": "..."
  },
  "grant_type": "user_token",
  "uaa": {
    "clientid": "sb-ut-decafbad-010b-4777-a642-31e75990d188-clone!b123443|cis-central!b14",
    "clientsecret": "174f9bf1-4242-4758-be09-2ed57b2c16d8$GwEq1MYya8yPACvBTLLWvodMOzlxWFGtZGvqTLd21jA=",
    "credential-type": "binding-secret",
    "identityzone": "8fe7efd4trial-ga",
    "url": "https://8fe7efd4trial-ga.authentication.eu10.hana.ondemand.com",
    "...": "..."
  }
}
```

Values in this JSON data are needed to:

* request an authorization token (with the `clientid`, `clientsecret` and `url` properties in the `uaa` object)
* make the actual API call (with the `entitlements_service_url` property in the `endpoints` object)

Background details on this are available in the SAP Help Portal page linked in the [Further reading](#further-reading) section below.

#### Request the token

Now you can request the token. It's essentially an HTTP request to an OAuth 2.0 endpoint with parameters supplying the grant type, username and password details, and authentication in the form of the `clientid` and `clientsecret` values above.

There's a script called [generate-password-grant-type](generate-password-grant-type) in this directory that you can run, and at the heart is this `curl` invocation, which gives you an idea of what's going to happen:

```bash
curl \
  --url "$uaa_url/oauth/token" \
  --location \
  --header 'Content-Type: application/x-www-form-urlencoded' \
  --user "$clientid:$clientsecret" \
  --data-urlencode 'grant_type=password' \
  --data-urlencode "username=$email" \
  --data-urlencode "password=$password"
```

👉 Run this script now, specifying the name of the file containing the service key JSON data:

```bash
./generate-password-grant-type cis-central-sk.json
```

You'll be asked for your username (where you should specify your email address) and your password. If the call is successful, you'll see some JSON output. A good sign! But it's more or less unreadable just output to the terminal in raw form.

👉 So repeat the invocation and save the output to a file; then you can pick out details with `jq`:

```bash
./generate-password-grant-type cis-central-sk.json > tokendata.json
```

> You can of course simply open the file in your Dev Space editor, but where's the fun in that? Also, it will be displayed as one, long, unreadable line.

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

See the reference to the "keys" section of the `jq` manual in the [Further reading](#further-reading) section below to read more on the "keys" function.

These properties look like the right ones - we have an access token that we can now use to authenticate the API call, and we even have a refresh token to ask for a new one when the current one expires.

### Make the call

You now have everything you need to make the call to the API endpoint. The simple script [call-entitlements-service-regions-api](call-entitlements-service-regions-api), also in this directory, will help you do this. Like the `generate-password-grant-type` script, it also requires the service key JSON data file (so it can retrieve the value of the `entitlements_service_url` endpoint) ... it also requires the name of the token data JSON file.

👉 Have a look at the script if you wish, then invoke it, passing the output to `jq` to prettify it:

```bash
./call-entitlements-service-regions-api cis-central-sk.json tokendata.json | jq .
```

You should see some output similar to this:

```json
{
  "datacenters": [
    {
      "name": "cf-ap21",
      "displayName": "Singapore - Azure",
      "region": "ap21",
      "environment": "cloudfoundry",
      "iaasProvider": "AZURE",
      "supportsTrial": true,
      "provisioningServiceUrl": "https://provisioning-service.cfapps.ap21.hana.ondemand.com",
      "saasRegistryServiceUrl": "https://saas-manager.cfapps.ap21.hana.ondemand.com",
      "domain": "ap21.hana.ondemand.com",
      "geoAccess": "BACKWARD_COMPLIANT_EU_ACCESS"
    },
    {
      "name": "cf-us10",
      "displayName": "US East (VA) - AWS",
      "region": "us10",
      "environment": "cloudfoundry",
      "iaasProvider": "AWS",
      "supportsTrial": true,
      "provisioningServiceUrl": "https://provisioning-service.cfapps.us10.hana.ondemand.com",
      "saasRegistryServiceUrl": "https://saas-manager.cfapps.us10.hana.ondemand.com",
      "domain": "us10.hana.ondemand.com",
      "geoAccess": "BACKWARD_COMPLIANT_EU_ACCESS"
    },
    {
      "name": "cf-eu10",
      "displayName": "Europe (Frankfurt) - AWS",
      "region": "eu10",
      "environment": "cloudfoundry",
      "iaasProvider": "AWS",
      "supportsTrial": false,
      "provisioningServiceUrl": "https://provisioning-service.cfapps.eu10.hana.ondemand.com",
      "saasRegistryServiceUrl": "https://saas-manager.cfapps.eu10.hana.ondemand.com",
      "domain": "eu10.hana.ondemand.com",
      "geoAccess": "BACKWARD_COMPLIANT_EU_ACCESS"
    }
  ]
}
```

Does this [look familiar](#use-the-json-format-output-option)? Of course it does. It's exactly the same as what `btp --format json list accounts/available-region` produced.

## Summary

At this point you know how to get the btp CLI to output the structured data in a more machine-parseable form, and you also understand the relationship between the btp CLI and the Cloud Management Service APIs.

## Further reading

* [Understanding OAuth 2.0 grant types](https://github.com/SAP-archive/cloud-apis-virtual-event/tree/main/exercises/02#3-understand-oauth-20-grant-types)
* [Getting an Access Token for SAP Cloud Management Service APIs](https://help.sap.com/products/BTP/65de2977205c403bbc107264b8eccf4b/3670474a58c24ac2b082e76cbbd9dc19.html?locale=en-US)
* [The builtin keys and keys_unsorted functions in jq](https://stedolan.github.io/jq/manual/#keys,keys_unsorted)

---

If you finish earlier than your fellow participants, you might like to ponder these questions. There isn't always a single correct answer and there are no prizes - they're just to give you something else to think about.

1. What Unix tool might you use to parse out the individual column values, say, to identify the region and provider values, from the text output in [Parsing the output](#parsing-the-output)?
1. Take a look at the token data you retrieved - what's the lifetime of the access token, in hours?
1. Have a bit of a stare at the [call-entitlements-service-regions-api](call-entitlements-service-regions-api) script, and the associated [lib.sh](lib.sh) library. Is there anything in there that you'd like to know more about?
