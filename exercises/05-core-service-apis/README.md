# Exercise 05 - Getting to know the Core Services for SAP BTP APIs

The btp CLI implementation has a client / server nature. The server component facilitates calls to APIs in the [Core Services for SAP BTP](https://api.sap.com/package/SAPCloudPlatformCoreServices/rest) package. So the btp CLI effectively gives you a comfortable way of consuming those APIs that are specifically designed to let you "manage, build, and extend the core capabilities of SAP BTP".

In this exercise you'll see that first hand, by observing that the JSON you saw in the previous exercise (emitted from `btp --format json list accounts/available-region`) is effectively the same as the output from a call to the corresponding API endpoint.

The main goal of this exercise is not the output, nor the examination thereof. It's the journey you're about to take to get to the stage where you can successfully and comfortably identify an endpoint and prepare & make an authenticated call to it.

## API structure

The endpoint in question lives within the [Entitlements Service](https://api.sap.com/api/APIEntitlementsService/overview) API, specifically within the "Regions for Global Account" group. You can see this in the SAP API Business Hub:

![Regions for Global Account endpoint](assets/regions-for-global-account.png)

It's worth pausing a second to think about how APIs are organized on the SAP API Business Hub. There are API packages, APIs, and endpoints that are collected into groups. The hierarchy is as follows, showing where this endpoint is:

```
+-------------+
|             |
| API Package |      Core Services for SAP BTP
|             |
+-------------+
       |
+-------------+
|             |
|     API     |      Entitlements Service
|             |
+-------------+
       |
+-------------+
|             |
|    Group    |      Regions for Global Account
|             |
+-------------+
       |
+-------------+
|             |
|  Endpoint   |      /entitlements/v1/globalAccountAllowedDataCenters
|             |
+-------------+
```

## Credentials for API calls

The API endpoints are protected, and calls to them require credentials. For OAuth 2.0 protected resources, these credentials are usually in the form of access tokens, long opaque strings of characters. In general, obtaining an access token involves using information related to an instance of a service (on SAP BTP) to which the API relates. This information is contained in a binding (also known as a service key in Cloud Foundry contexts).

So to get to the stage where an access token is obtained, an instance of a service is created. When creating a service instance, a plan for that service must be specified. From the instance, a binding can then be created. And using information in this binding, an access token can be requested. There are different flows, also known as "grant types", that describe how the request is made. Once the access token is received, it can be used to authenticate the API call.

While we're in the mood for ASCII art, here's that in diagram form:

```
+----------------+      +----------------+      +----------------+
|    Service     |      |    Instance    |      |    Binding     |
|                |--+-->|                |----->|                |
|                |  |   |                |      |                |
+----------------+  |   +----------------+      +----------------+
        |           |                                   |
        |           |                                   |
        |           |                                   |
+----------------+  |                                   |
|      Plan      |  |                                   |
|                |--+                                   |
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

## Making a Core Services for SAP BTP API call

In this exercise we're going to make a call to the one endpoint in the Regions for Global Account group, i.e. to:

```
/entitlements/v1/globalAccountAllowedDataCenters
```

### Setting up to request a token

The endpoints in the Entitlement Service API are protected by the OAuth 2.0 "Resource Owner Password Credentials" grant type, otherwise known as the "Password" grant type (this grant type is considered legacy, but is still used to protect some resources in this area). See the link to understanding OAuth 2.0 grant types in the [Further reading](#further-reading) section below for more background information.

👉 Head over to the [Entitlements Service API overview](https://api.sap.com/api/APIEntitlementsService/overview) page on the SAP API Business Hub.

👉 Find and follow the link to the [Account Administration Using APIs of the SAP Cloud Management Service](https://help.sap.com/docs/BTP/65de2977205c403bbc107264b8eccf4b/17b6a171552544a6804f12ea83112a3f.html?locale=en-US) section in the SAP Help Portal, where you'll see something like this:

![Account Administration documentation page](/assets/account-admin-docu-page.png)

👉 Explore the two nodes highlighted in red, to see that it's the "SAP Cloud Management" service that is relevant here, and that the technical name for this service is `cis`. See also that there are two plans for the SAP Cloud Management service: `central` and `local`.

The `central` plan affords a little more access than the `local` plan so we'll go for the `central` plan. This is where these values fit into our diagram:

```
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

There are different places that a service instance can be created, but [as you have a Cloud Foundry environment set up](../../prerequisites.md#subaccount-and-cloud-foundry-environment), we'll use that.

#### Determine your CF API endpoint

So the choice of Cloud Foundry (CF) as an environment for the service instance means that, in a similar way to how we logged in with the btp CLI, we now must log in with the CF CLI, `cf`, so that we can use that tool to create the service instance.

To log in, this we need to know which endpoint we must connect to, which we will do, shortly, like this:

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
