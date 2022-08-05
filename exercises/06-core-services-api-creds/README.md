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

👉 Ensure you're in the directory containing this `README.md` file and the `get_cf_api_endpoint` script, and make this call (replacing `trial` with the name of your subaccount):

```bash
cd $HOME/projects/cloud-btp-cli-api-codejam/exercises/06-core-services-api-creds
cf login -a $(./get_cf_api_endpoint "trial")
```

Supply your BTP trial account credentials (email address and password). Here's what the flow will look like:

```text
user: 06-core-services-api-creds $ cf login -a $(./get_cf_api_endpoint "trial")
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

> You should already have a space set up, as described in the [Subaccount and Cloud Foundry environment](../../prerequisites.md#subaccount-and-cloud-foundry-environment) section of the prerequisites.

## Create a service instance and key

👉 Now you're authenticated, create an instance of the Cloud Management Service, with the "central" plan, as discussed earlier:

> If you already have an instance of this service, you may need to remove it so that you can create this one.

```bash
cf create-service cis central cis-central
```

The output should look something like this:

```text
Creating service instance cis-central in org 8fe7efd4trial / space dev as qmacro+blue@gmail.com...
OK
```

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
Getting key cis-central-sk for service instance cis-central as qmacro+blue@gmail.com...

{
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
  "clientid": "sb-ut-cafe4267-d070-4e8e-8710-2de0ae46b85f-clone!b123443|cis-central!b14",
  "clientsecret": "c663b1ca-cafe-42-b2b2-d45313c39c80$fKncNz2FM89P8m6M1uTRod07VzDRsI_ddf7cR7hKp5w=",
  "credential-type": "binding-secret",
  "identityzone": "8fe7efd4trial-ga",
  "identityzoneid": "fdce9323-d6e6-cafe-8df0-5e501c90a2be",
  "sburl": "https://internal-xsuaa.authentication.eu10.hana.ondemand.com",
  "subaccountid": "fdce9323-d6e6-42e6-cafe-5e501c90a2be",
  "tenantid": "fdce9323-d6e6-cafe-8df0-5e501c90a2be",
  "tenantmode": "shared",
  "uaadomain": "authentication.eu10.hana.ondemand.com",
  "url": "https://8fe7efd4trial-ga.authentication.eu10.hana.ondemand.com",
  "verificationkey": "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAyfJwIO6n853DLxeBDl7Z\nqUKh4RA3yJ1gBNoBw0F2JZx2F3DaZcafekpupEW46n+8UKh/jUcESdve/feePWYW\nPo/tW/bPKHwDW2NmTXZ1Rid3AVYiguUwGzJjmeLb/aeqPWjl4PdLT0uZKtvW+Ljm\nlSHQ4NUEJf/n3hYomjlTNagx0dpNCZ6u+cKZ4Nm5wO58fVI4oyvpUhVhSR6xo8A2\nJ5nya+misMohHqdQcvqElmd+uUr6jN9k7tn4VUl8aw1MlL/Uy3D0YZFOPim9OIv6\nYkpIChxDHyrb+vplWhDVlTZt9zCR1MzPIiK6xLUqVAwCEbuxolo0w/CTJPGr98d2\newIDAQAB\n-----END PUBLIC KEY-----",
  "xsappname": "ut-c9426667-d070-cafe-8710-2de0ae46b85f-clone!b123443|cis-central!b14",
  "xsmasterappname": "cis-central!b14",
  "zoneid": "fdce9323-d6e6-42e6-cafe-5e501c90a2be"
 }
}
```

The next thing to do is to save this content to a file. First, so we don't need to keep calling `cf service-key`, but mostly so we can parse information out of it, because that's easy with `jq` as it's JSON, right?

Well, not quite.

The eagle-eyed amongst you will have spotted there's some extra output from `cf service-key` that we need to get rid of first before redirecting the rest of it to a file. And that's the first two "helpful" lines (in case you're wondering, the second line is a blank line):

```text
Getting key cis-central-sk for service instance cis-central as qmacro+blue@gmail.com...

```

So we need to pass the output through something so we can remove these lines.

> Some CF proponents would at this stage point to specific access to the API endpoint facility afforded by the `cf curl` command, as described in [curl - Cloud Foundry CLI Reference Guide](https://cli.cloudfoundry.org/en-US/v7/curl.html). However, to have a separate, incompatible set of objects and API shapes, just to be able to have a cleaner output on the command line, is contrary to the Unix Philosophy and is not an ideal alternative for ad hoc contexts such as this.

To make the cleanup, the venerable [sed](https://www.gnu.org/software/sed/manual/sed.html) will do nicely.

👉 Re-run the previous `cf` command, but this time, pipe the output into `sed`, specifying a short script to delete lines 1 and 2, and then redirect the output of that into a file `cis-central-sk.json`:

```bash
cf service-key cis-central cis-central-sk | sed '1,2d' > cis-central-sk.json
```

You can check the file contains just the JSON by asking `jq` to print it out nicely:

👉 Try that now:

```bash
jq . cis-central-sk.json
```

You should see a nicely formatted display of JSON.

> Technically speaking, the `.` in `jq` is the [identity](https://stedolan.github.io/jq/manual/#Identity:.) filter, so the nice formatting of the JSON is actually just a by-product of asking `jq` to filter the JSON through the identity filter (which just produces whatever it receives), and by default `jq` will endeavour to pretty-print the output.

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

1. What other naming conventions for Cloud Foundry instances and service keys have you seen? Are there ones you prefer to use, and if so, what are they?
1. Take a look at the token data you retrieved - what's the lifetime of the access token, in hours?
1. Have a bit of a stare at the [call-entitlements-service-regions-api](call-entitlements-service-regions-api) script, and the associated [lib.sh](lib.sh) library. Is there anything in there that you'd like to know more about?
