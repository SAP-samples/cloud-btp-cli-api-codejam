# Exercise 09 - Deleting resources with the API

You've created resources with the btp CLI in the previous exercise, specifically a directory and a subaccount. In this exercise, to layer on a bit more experience and understanding, you're going to remove those resources using the appropriate API.

## Make the necessary preparations

It's worth double-checking what you're going to delete, and to get everything ready for action.

### Identify the directory and subaccount to delete

👉 Have a look at the hierarchy of directories and subaccounts:

```bash
btp get accounts/global-account --show-hierarchy | trunc
```

In the output that ensues, identify the directory and subaccount that you created in the previous exercise. The output should look similar to this, and you can see the parent/child relationship between the two resources (highlighted with arrows):

```text
Showing details for global account fdce9323-d6e6-42e6-8df0-5e501c90a2be...

├─ 8fe7efd4trial (fdce9323-d6e6-42e6-8df0-5e501c90a2be - global account)
│  ├─ trial (f78e0bdb-c97c-4cbc-bb06-526695f44551 - subaccount)
│  ├─ codejam-directory (f4c7d60e-627c-4fab-8e67-603b20b84f72 - directory)          <----
│  │  ├─ codejam-subaccount (be63bfda-070a-49a8-ab26-03153b16617e - subaccount)     <----

type:            id:                                    display name:        parent id:                             parent
global account   fdce9323-d6e6-42e6-8df0-5e501c90a2be   8fe7efd4trial
subaccount       cd76fdef-16f8-47a3-954b-cab6678cc24d   testsubaccount       fdce9323-d6e6-42e6-8df0-5e501c90a2be   global
subaccount       f78e0bdb-c97c-4cbc-bb06-526695f44551   trial                fdce9323-d6e6-42e6-8df0-5e501c90a2be   global
directory        f4c7d60e-627c-4fab-8e67-603b20b84f72   codejam-directory    fdce9323-d6e6-42e6-8df0-5e501c90a2be   global
subaccount       be63bfda-070a-49a8-ab26-03153b16617e   codejam-subaccount   f4c7d60e-627c-4fab-8e67-603b20b84f72   direct
```

👉 Check that you can still use the `btpguid` script (that you created a symbolic link to in your `$HOME/bin/` directory in the previous exercise) to get the GUIDs of these resources:

```bash
btpguid codejam-directory; btpguid codejam-subaccount
```

You should see output similar to this - i.e. the two GUIDs:

```text
f4c7d60e-627c-4fab-8e67-603b20b84f72
be63bfda-070a-49a8-ab26-03153b16617e
```

### Identify the appropriate API endpoint

In a previous exercise, we used the `/entitlements/v1/globalAccountAllowedDataCenters` endpoint of the Entitlements Service API. This time, we need to look at endpoints in the Accounts Service API.

![The Core Services APIs](assets/core-services-apis.png)

👉 Take a moment to look at the [API reference for the Entitlements Service API](https://api.sap.com/api/APIEntitlementsService/resource), and you'll see that there are three groups of endpoints:

* Manage Assigned Entitlements
* Regions for Global Account
* Job Management

![Entitlements Service API endpoint groups](assets/entitlements-endpoint-groups.png)

> The Job Management group contains a single generic endpoint that is common to many of the APIs in this package.

The endpoint we used was within the "Regions for Global Account" group.

This time, we need to find an endpoint that supports operations on directories and subaccounts, and in the Core Services APIs overview we can see that the description for the Accounts Service API sounds like what we're looking for: "_Manage the directories and subaccounts in your global account's structure._"

👉 Select the [Accounts Service API](https://api.sap.com/api/APIAccountsService/overview) in the SAP API Business Hub, go to the [API Reference](https://api.sap.com/api/APIAccountsService/resource) section, and take note of the endpoint groups, which are:

* Directory Operations
* Global Account Operations
* Subaccount Operations
* Job Managment

Within the Directory Operations group, you'll see that there's a specific combination of HTTP method and endpoint thus:

```text
DELETE /accounts/v1/directories/{directoryGUID}
```

### Check we have the right access

👉 Take a look at this endpoint, the required scope, and the parameters:

![delete directory endpoint options](assets/delete-directory-endpoint-options.png)

Back in [Exercise 05 - Preparing to call a Core Services API](https://github.com/SAP-samples/cloud-btp-cli-api-codejam/blob/main/exercises/05-core-services-api-prep/README.md), specifically in the section [Understanding what's required for a token request](https://github.com/SAP-samples/cloud-btp-cli-api-codejam/blob/main/exercises/05-core-services-api-prep/README.md#understanding-whats-required-for-a-token-request), we noted that the `central` plan for the SAP Cloud Management service for SAP BTP (`cis`) provided greater access.

👉 Go back to the [SAP Cloud Management - Service Plans](https://help.sap.com/docs/BTP/65de2977205c403bbc107264b8eccf4b/a508b724bf6d457ca7ac024b8e4b8457.html?locale=en-US) and check through the scopes offered with the `central` plan. Make sure you can see that it offers this scope:

```text
global-account.account-directory.delete
```

This is the scope that we see as a requirement to be able to make a DELETE request to this `/accounts/v1/directories/{directoryGUID}` endpoint.

So with our current access token, we should be all set. Right?

Well, yes, but "we should be all set" is a bit vague, don't you think? Let's spend a couple of minutes verifying this.

Back when we [requested the token in Exercise 06](https://github.com/SAP-samples/cloud-btp-cli-api-codejam/blob/main/exercises/06-core-services-api-creds/README.md#request-the-token) we got a whole blob of data, first to the terminal, and then captured into a file `tokendata.json`.

We'll want to take a closer look at this data, so let's make the file available in the directory related to this exercise.

👉 Move to the appropriate directory and create a symbolic link to the file:

```bash
cd $HOME/projects/cloud-btp-cli-api-codejam/exercises/09-deleting-resources-with-api/
ln -s ../06-core-services-api-creds/tokendata.json .
```

👉 Check you can explore the contents from this same directory, like this:

```bash
jq keys tokendata.json
jq .access_token tokendata.json
```

This should show you the keys (properties) in the JSON contained in `tokendata.json`, along with the big lump that is the access token.

> Unless you're taking this CodeJam very slowly, over days, the access token should still be good - it lasts for 12 hours (you can use `jq -r '.expires_in / 60 / 60 | round' tokendata.json` to check).

Let's examine that "big lump" that is the access token. There doesn't seem to be much (if any) structure to it, but if we know what it is, we can find the tools to help us. There's an open Web standard [RFC7519](https://www.rfc-editor.org/rfc/rfc7519), otherwise known as "JSON Web Token". This is shortened to "JWT" and is commonly pronounced as "jot" (make of that what you will). You can find a link to an introduction to JWTs in the [Further reading](#further-reading) section.

There are many tools that can help you with JWTs. One is `jwt`, which will parse and display the contents of a JWT. Let's use it to look inside the access token.

👉 In your Dev Space, you already have a Node.js runtime, and along with that, the `npm` package manager. Use that to install the `jwt-cli` package, globally; this package contains the `jwt` command line interface:

```bash
npm install -g jwt-cli
```

Now you can send the value of the access token to this command and it will parse it and display the contents.

👉 Try it now, like this:

```bash
jq --raw-output .access_token tokendata | jwt
```

Along with other output, you should see various sections displayed, something like this:

```text
✻ Header
{
  "alg": "RS256",
  "jku": "https://8fe7efd4trial-ga.authentication.eu10.hana.ondemand.com/token_keys",
  "kid": "default-jwt-key--57cafe828",
  "typ": "JWT"
}

✻ Payload
{
  "jti": "e7858cafea9344f392f0dc8b64bdc014",
  "ext_attr": {
    "enhancer": "XSUAA",
    "globalaccountid": "fdce9323-d6e6-42e6-8df0-5e501c90a2be",
    "zdn": "8fe7efd4trial-ga",
    "serviceinstanceid": "4a66cafe-6978-4c05-9fb4-95dac2a625b3"
  },
  "xs.system.attributes": {
    "xs.rolecollections": [
      "Global Account Administrator"
    ]
  },
  "given_name": "Blue",
  "xs.user.attributes": {},
  "family_name": "Adams",
  "sub": "0fe5eeef-60aa-4607-9bbe-2aacafe89347",
  "scope": [
    "cis-central!b14.global-account.subaccount.update",
    "cis-central!b14.global-account.update",
    "cis-central!b14.global-account.subaccount.delete",
    "cis-central!b14.global-account.subaccount.read",
    "cis-central!b14.job.read",
    "cis-central!b14.catalog.product.update",
    "cis-central!b14.catalog.product.delete",
    "cis-central!b14.global-account.account-directory.create",
    "cis-central!b14.directory.entitlement.update",
    "cis-central!b14.global-account.entitlement.read",
    "xs_account.access",
    "cis-central!b14.event.read",
    "cis-central!b14.directory.entitlement.read",
    "cis-central!b14.global-account.account-directory.read",
    "openid",
    "cis-central!b14.global-account.entitlement.subaccount.update",
    "cis-central!b14.global-account.account-directory.update",
    "uaa.user",
    "cis-central!b14.global-account.read",
    "cis-central!b14.global-account.account-directory.delete",
    "cis-central!b14.global-account.region.read",
    "cis-central!b14.global-account.subaccount.create"
  ],
  "client_id": "sb-ut-a71edd26-eb55-4443-adff-402fe561cafe-clone!b123443|cis-central!b14",
  "cid": "sb-ut-a71edd26-eb55-4443-adff-402fe561cafe-clone!b123443|cis-central!b14",
  "azp": "sb-ut-a71edd26-eb55-4443-adff-402fe561cafe-clone!b123443|cis-central!b14",
  "grant_type": "password",
  "user_id": "0fe5eeef-60aa-4607-9bbe-2aa2a5cafe47",
  "origin": "sap.default",
  "user_name": "qmacro+blue@gmail.com",
  "email": "qmacro+blue@gmail.com",
  "auth_time": 1660912670,
  "rev_sig": "be1d11ba",
  "iat": 1660912670,
  "exp": 1660955870,
  "iss": "https://8fe7efd4trial-ga.authentication.eu10.hana.ondemand.com/oauth/token",
  "zid": "fdcafe23-d6e6-42e6-8df0-5e501c90a2be",
  "aud": [
    "cis-central!b14.global-account.subaccount",
    "openid",
    "xs_account",
    "cis-central!b14.global-account.entitlement.subaccount",
    "cis-central!b14.global-account.region",
    "sb-ut-a71edd26-eb55-4443-adff-402fe5612a9b-clone!b123443|cis-central!b14",
    "cis-central!b14.global-account.entitlement",
    "cis-central!b14.event",
    "cis-central!b14.global-account.account-directory",
    "cis-central!b14.directory.entitlement",
    "cis-central!b14.global-account",
    "uaa",
    "cis-central!b14.catalog.product",
    "cis-central!b14.job"
  ]
}
   iat: 1660912670 8/19/2022, 12:37:50 PM
   exp: 1660955870 8/20/2022, 12:37:50 AM

✻ Signature wQOTOYR61Gz_H0nvM8Dyiv4qIPnHDtJSbBFRuA4HF4ExyVKQBxbGzVXG5qr6mtaWthVLms4X_CwsXV1uLVhtVQJdq1SChFnpDHDJVlRvygIQOnkyZuZhXc4ssIsBJT2rgv95fWY9ICERWCZtbjyIqtZ21fxbdSUhlizr3bcJsvpLloX7clwe2JUANK5eAoh6Zsiy3f_qpgUC2TWf0rjimz8TEN19mxormy3RGCtO7pHAUiU-2hPIjOAsAzm4p742URlsS1xlvnWatmHix--VduiBpHs-QRt1pCgZkqWQDdSKWgaSPGguThCTy7Zn2jcWLtQDb2jLWFb-zWASPvcGOA
```

That's wonderful! We can see within the "scope" section of the payload that the scope we need is indeed there:

```json
"cis-central!b14.global-account.account-directory.delete"
```

In fact, with our lights-out hats on, we would want to go one step further to be able to automate the checking of this, if we needed to. Rather than have to visually identify the appropriate section in the output, we can use the `--output=json` option with `jwt` to get a predictable and parseable output in JSON format, that we can then feed into `jq` to pick out what we want.

👉 Try this now:

```bash
jq -r .access_token tokendata.json \
  | jwt --output=json \
  | jq .payload.scope
```

This gives us something like this:

```json
[
  "cis-central!b14.global-account.subaccount.update"
  "cis-central!b14.global-account.update"
  "cis-central!b14.global-account.subaccount.delete"
  "cis-central!b14.global-account.subaccount.read"
  "cis-central!b14.job.read"
  "cis-central!b14.catalog.product.update"
  "cis-central!b14.catalog.product.delete"
  "cis-central!b14.global-account.account-directory.create"
  "cis-central!b14.directory.entitlement.update"
  "cis-central!b14.global-account.entitlement.read"
  "xs_account.access"
  "cis-central!b14.event.read"
  "cis-central!b14.directory.entitlement.read"
  "cis-central!b14.global-account.account-directory.read"
  "openid"
  "cis-central!b14.global-account.entitlement.subaccount.update"
  "cis-central!b14.global-account.account-directory.update"
  "uaa.user"
  "cis-central!b14.global-account.read"
  "cis-central!b14.global-account.account-directory.delete"
  "cis-central!b14.global-account.region.read"
  "cis-central!b14.global-account.subaccount.create"
]
```

We can of course go one step further and look for the scopes that describe the delete level, like this:

```bash
jq -r .access_token tokendata.json \
  | jwt --output=json \
  | jq '
      .payload.scope
      | map(select(.|endswith(".delete")))
    '
```

This will give us a smaller list to check:

```json
[
  "cis-central!b14.global-account.subaccount.delete",
  "cis-central!b14.catalog.product.delete",
  "cis-central!b14.global-account.account-directory.delete"
]
```

### Check the service URL

We've identified that the endpoint we want looks like this: `/accounts/v1/directories/{directoryGUID}`. This is relative, of course, and must be suffixed to the Accounts Service API's service URL. Where's that? It's in the same place that we found the service URL for the Entitlements Service API, i.e. in the service key (binding) information. So let's look in there.

👉 Just like you did for the `tokendata.json` file, create a symbolic link in this exercise's directory to the `cis-central-sk.json` file we created back in Exercise 06:

```bash
ln -s ../06-core-services-api-creds/cis-central-sk.json .
```

> We don't of course absolutely need references to these files in our current directory, but it's a bit more comfortable when referring to them.

👉 Let's now remind ourselves of the top level properties in this service key information:

```bash
jq keys cis-central-sk.json
```

You should see a list of keys like this:

```json
[
  "endpoints",
  "grant_type",
  "sap.cloud.service",
  "uaa"
]
```

👉 Now dig in to the `endpoints` key:

```bash
jq .endpoints cis-central-sk.json
```

You'll see output similar to this, which should include an `accounts_service_url` key and value:

```json
{
  "accounts_service_url": "https://accounts-service.cfapps.eu10.hana.ondemand.com",
  "cloud_automation_url": "https://cp-formations.cfapps.eu10.hana.ondemand.com",
  "entitlements_service_url": "https://entitlements-service.cfapps.eu10.hana.ondemand.com",
  "events_service_url": "https://events-service.cfapps.eu10.hana.ondemand.com",
  "external_provider_registry_url": "https://external-provider-registry.cfapps.eu10.hana.ondemand.com",
  "metadata_service_url": "https://metadata-service.cfapps.eu10.hana.ondemand.com",
  "order_processing_url": "https://order-processing.cfapps.eu10.hana.ondemand.com",
  "provisioning_service_url": "https://provisioning-service.cfapps.eu10.hana.ondemand.com",
  "saas_registry_service_url": "https://saas-manager.cfapps.eu10.hana.ondemand.com"
}
```

So we can see that the service URL is `https://accounts-service.cfapps.eu10.hana.ondemand.com`.

## Make the call

We now have everything we need to make the call, [just like we did in an earlier exercise](https://github.com/SAP-samples/cloud-btp-cli-api-codejam/blob/main/exercises/07-core-services-api-call/README.md#make-the-call).

Let's do it. We'll determine the dynamic values step by step and assign them to variables, rather than try to do everything in one go.

👉 Save the service URL in a variable, and also the GUID of the directory:

```bash
url=$(jq --raw-output .endpoints.accounts_service_url cis-central-sk.json)
guid=$(btpguid codejam-directory)
```

👉 Now use these in the `curl` invocation, along with the access token:

```bash
curl \
  --url "$url/accounts/v1/directories/$guid" \
  --header "Authorization: Bearer $(jq -r .access_token tokendata.json)"
```

## Further reading

* [Introduction to JSON Web Tokens](https://jwt.io/introduction)

---

If you finish earlier than your fellow participants, you might like to ponder these questions. There isn't always a single correct answer and there are no prizes - they're just to give you something else to think about.
