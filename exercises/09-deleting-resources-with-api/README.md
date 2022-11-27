# Exercise 09 - Deleting resources with the API

You've created resources with the btp CLI in the previous exercise, specifically a directory and a subaccount. In this exercise, to layer on a bit more experience and understanding, you're going to remove those resources using the appropriate API, and as a bonus, make another call to the jobs management API to see the status of the deletion operation, which is asynchronous.

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
* Job Management

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

The access token is a JWT.

There are many tools that can help you with JWTs. One is `jwt`, which will parse and display the contents of a JWT. Let's use it to look inside the access token.

In your working environment, you already have a Node.js runtime, and along with that, the `npm` package manager. There's a handy `jwt-cli` package that contains the `jwt` command line interface. Let's install that. We'll install it "globally" so it's independent of any NPM project. But that "global" location will be just local to us.

👉 First, set a custom prefix for `npm` in the configuration, and make sure the location that the prefix points to exists as a directory:

```bash
npm config set prefix $HOME/npm/
mkdir $HOME/npm/
```

👉 Now install the package, using the `--global` option (which can be shortened to `-g`):

```bash
npm install -g jwt-cli
```

👉 To satisfy your curiosity, have a look at what has been installed, like this:

```bash
find $HOME/npm/ -maxdepth 5
```

This should produce output that looks something like this:

```text
/home/user/npm
/home/user/npm/lib
/home/user/npm/lib/node_modules
/home/user/npm/lib/node_modules/jwt-cli
/home/user/npm/lib/node_modules/jwt-cli/.prettierrc.json
/home/user/npm/lib/node_modules/jwt-cli/.prettierignore
/home/user/npm/lib/node_modules/jwt-cli/src
/home/user/npm/lib/node_modules/jwt-cli/src/input.js
/home/user/npm/lib/node_modules/jwt-cli/src/jwt.js
/home/user/npm/lib/node_modules/jwt-cli/src/output.js
/home/user/npm/lib/node_modules/jwt-cli/index.js
/home/user/npm/lib/node_modules/jwt-cli/LICENSE.txt
/home/user/npm/lib/node_modules/jwt-cli/CONTRIBUTING.md
/home/user/npm/lib/node_modules/jwt-cli/README.md
/home/user/npm/lib/node_modules/jwt-cli/package.json
/home/user/npm/lib/node_modules/jwt-cli/node_modules
/home/user/npm/lib/node_modules/jwt-cli/node_modules/minimist
/home/user/npm/lib/node_modules/jwt-cli/node_modules/ecdsa-sig-formatter
/home/user/npm/lib/node_modules/jwt-cli/node_modules/fast-jwt
/home/user/npm/lib/node_modules/jwt-cli/node_modules/safer-buffer
/home/user/npm/lib/node_modules/jwt-cli/node_modules/obliterator
/home/user/npm/lib/node_modules/jwt-cli/node_modules/safe-buffer
/home/user/npm/lib/node_modules/jwt-cli/node_modules/mnemonist
/home/user/npm/lib/node_modules/jwt-cli/node_modules/bn.js
/home/user/npm/lib/node_modules/jwt-cli/node_modules/inherits
/home/user/npm/lib/node_modules/jwt-cli/node_modules/color-convert
/home/user/npm/lib/node_modules/jwt-cli/node_modules/color-name
/home/user/npm/lib/node_modules/jwt-cli/node_modules/has-flag
/home/user/npm/lib/node_modules/jwt-cli/node_modules/minimalistic-assert
/home/user/npm/lib/node_modules/jwt-cli/node_modules/asn1.js
/home/user/npm/lib/node_modules/jwt-cli/node_modules/ansi-styles
/home/user/npm/lib/node_modules/jwt-cli/node_modules/chalk
/home/user/npm/lib/node_modules/jwt-cli/node_modules/supports-color
/home/user/npm/bin
/home/user/npm/bin/jwt
```

👉 Take note of the item `/home/user/npm/bin/jwt` - that's the executable that we need. Let's create a symbolic link to it in our `$HOME/bin/` directory where the rest of our custom executables are, and then check to see what it looks like:

```bash
ln -s $HOME/npm/bin/jwt $HOME/bin/
ls -l $HOME/bin/jwt
```

This should show the link, something like this:

```text
lrwxrwxrwx 1 user user 22 Sep  8 13:36 /home/user/bin/jwt -> /home/user/npm/bin/jwt
```

Now we have a `jwt` executable that we can use from anywhere.

👉 Try it now, sending the value of the access token, and it will parse it and display the contents.

```bash
jq --raw-output .access_token tokendata.json | jwt
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

Let's do it, taking a cautious first step, then committing to the deletion.

We'll determine the dynamic values step by step and assign them to variables, rather than try to do everything in one go.

👉 Save the service URL in a variable, and also the GUID of the directory:

```bash
url=$(jq --raw-output .credentials.endpoints.accounts_service_url cis-central-sk.json)
guid=$(btpguid codejam-directory)
```

### Using HTTP GET to read the information

Starting cautiously, let's try first to read the directory information, using the HTTP GET method. If you check the Directory Operations group of endpoints for the [Accounts Service API](https://api.sap.com/api/APIAccountsService/resource) you'll see that there's a family of HTTP method + URL path combinations:

* `GET    /accounts/v1/directories/{directoryGUID}` (read)
* `DELETE /accounts/v1/directories/{directoryGUID}` (delete)
* `PATCH  /accounts/v1/directories/{directoryGUID}` (update)

👉 OK, try to read the directory information with this `curl` invocation:

```bash
curl \
  --url "$url/accounts/v1/directories/$guid" \
  --header "Authorization: Bearer $(jq -r .access_token tokendata.json)" \
  | jq .
```

> This invocation also uses the access token from the `tokendata.json` file like we did in the previous API call. It also will default to the HTTP GET method.

After the progress bar that `curl` displays (remember, you can suppress this with `--silent`), you should see something like this:

```json
{
  "guid": "f4c7d60e-627c-4fab-8e67-603b20b84f72",
  "parentType": "ROOT",
  "globalAccountGUID": "fdce9323-d6e6-42e6-8df0-5e501c90a2be",
  "displayName": "codejam-directory",
  "createdDate": 1660820297434,
  "createdBy": "qmacro+blue@gmail.com",
  "modifiedDate": 1660820297434,
  "entityState": "OK",
  "stateMessage": "Directory created.",
  "directoryType": "FOLDER",
  "directoryFeatures": [
    "DEFAULT"
  ],
  "contractStatus": "ACTIVE",
  "consumptionBased": false,
  "parentGuid": "fdce9323-d6e6-42e6-8df0-5e501c90a2be",
  "parentGUID": "fdce9323-d6e6-42e6-8df0-5e501c90a2be"
}
```

Great, that's the information for the directory that we're about to delete.

### Trying HTTP DELETE to bring about the deletion

👉 Now make another call, this time explicitly specifying the DELETE method:

```bash
curl \
  --request DELETE \
  --url "$url/accounts/v1/directories/$guid" \
  --header "Authorization: Bearer $(jq -r .access_token tokendata.json)" \
  | jq .
```

This is the sort of response that you should see

```json
{
  "error": {
    "code": 20013,
    "message": "Could not delete entity with GUID f4c7d60e-627c-4fab-8e67-603b20b84f72. Entity is not empty.",
    "target": "/accounts/v1/directories/f4c7d60e-627c-4fab-8e67-603b20b84f72",
    "correlationID": "8ba8c975-6661-4e02-4fba-912455b6a36b"
  }
}
```

The response makes sense, and is preventing us from doing something that we might not want to do.

👉 Just because we're curious, let's have a look to see what HTTP response code is returned when we try this; first, add the `--verbose` option to `curl` to ask it to tell us everything that's going on, and also remove the pipe to `jq`, as the response will be a mix of text (the verbose output) and JSON (the response body) which of course `jq` will not parse:

```bash
curl \
  --request DELETE \
  --verbose \
  --url "$url/accounts/v1/directories/$guid" \
  --header "Authorization: Bearer $(jq -r .access_token tokendata.json)"
```

In the response header output (the lines are denoted by the `<` symbol) we should see this one:

```text
< HTTP/1.1 409 Conflict
```

The [409 Conflict](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/409) response status is appropriate, for two reasons:

* it's in the 4xx series, denoting it was the client (i.e. us) that is in error, not the server (see the [Further reading](#further-reading) section for a link to a 2 minute video on HTTP where this is covered)
* it indicates a request conflict with the current state of the target resource (in this case the directory), which is true ("entity is not empty")

### Trying the HTTP DELETE again, this time with forceDelete

In the scope and parameter detail of the `/accounts/v1/directories/{directoryGUID}` endpoint that we looked at earlier in [Check we have the right access](#check-we-have-the-right-access), you might have noticed this parameter:

```text
forceDelete
```

This is a boolean parameter that is false by default. Setting it to true will specify that we want the directory and everything it might contain to be deleted. Note that the parameter is specified with the word `(query)`, signifying that it should be specified in the query string (i.e. as part of the URL), rather than as a name/value pair in any sort of request payload. Let's try that now.

👉 Use this `curl` invocation, noting the addition of the query string, and the use of braces around the variable name to ensure that it doesn't get mixed up with any subsequent query string characters (this is shell parameter expansion, see [Further reading](#further-reading) for more details)):

```bash
curl \
  --request DELETE \
  --verbose \
  --url "$url/accounts/v1/directories/${guid}?forceDelete=true" \
  --header "Authorization: Bearer $(jq -r .access_token tokendata.json)" \
  | jq .
```

This should return fairly quickly, but successfully, and produce output like this:

```json
{
  "guid": "f4c7d60e-627c-4fab-8e67-603b20b84f72",
  "parentType": "ROOT",
  "globalAccountGUID": "fdce9323-d6e6-42e6-8df0-5e501c90a2be",
  "displayName": "codejam-directory",
  "createdDate": 1660820297434,
  "createdBy": "qmacro+blue@gmail.com",
  "modifiedDate": 1660921399071,
  "entityState": "DELETING",
  "directoryType": "FOLDER",
  "directoryFeatures": [
    "DEFAULT"
  ],
  "contractStatus": "ACTIVE",
  "consumptionBased": false,
  "parentGuid": "fdce9323-d6e6-42e6-8df0-5e501c90a2be",
  "parentGUID": "fdce9323-d6e6-42e6-8df0-5e501c90a2be"
}
```

It's the same output that we saw when we used the HTTP GET method. So what's going on?

Well, first of all, we can see that the `entityState` now has a value of `DELETING`. So that's a good sign. Moreover, because we used the `--verbose` option, we can have a closer look at the details of what's returned; you should see some HTTP response headers in the output, similar to this:

```text
< HTTP/1.1 200 OK
< cache-control: no-cache, no-store, max-age=0, must-revalidate
< content-type: application/json
< date: Fri, 19 Aug 2022 15:03:18 GMT
< expires: 0
< location: /jobs-management/v1/jobs/8926898/status
< pragma: no-cache
< vary: origin,access-control-request-method,access-control-request-headers,accept-encoding
< x-content-type-options: nosniff
< x-correlationid: f58ca769-44f6-41e4-7ab7-300d83c192b7
< x-frame-options: DENY
< x-vcap-request-id: f58ca769-44f6-41e4-7ab7-300d83c192b7
< x-xss-protection: 1; mode=block
< transfer-encoding: chunked
< strict-transport-security: max-age=31536000; includeSubDomains; preload;
```

Note the `location` header in the response. It points to a relative URL that looks like this:

```text
/jobs-management/v1/jobs/8926898/status
```

Guess what that relates to? Yes, the deletion activity is asynchronous, and is handled in a background job. And yes, the Job Management endpoint group that we saw briefly earlier is directly related to this.

### Checking the deletion job status

Let's finish this exercise with a final API call, this time to the single endpoint in the [Accounts Service](https://api.sap.com/api/APIAccountsService/resource) Job Management endpoint group:

```text
/jobs-management/v1/jobs/{jobInstanceIdOrUniqueId}/status
```

From our foray into the scopes that we have in our access token, we might have noticed that we have the scope that we need to make this API call, too:

```json
"cis-central!b14.job.read"
```

So let's get to it!

👉 Make another `curl` invocation; this time you'll have to copy the job instance ID from your HTTP response headers, or indeed the entire value of the `Location` header:

```bash

curl \
  --url "$url/jobs-management/v1/jobs/8926898/status" \
  --header "Authorization: Bearer $(jq -r .access_token tokendata.json)" \
  | jq .
```

Depending on how fast you are, and how slow the deletion is taking, you'll get some sort of response that tells you where the job is at. Here's an example of what you might get:

```json
{
  "status": "COMPLETED"
}
```

Great! Not only is the job complete, but this exercise is complete too. Well done!

## Summary

At this point your confidence in discovering APIs, preparing what you need to call them, and making the calls, should have grown. Not only that, you've experienced all this at the lowest level, where you can see everything that is going on, and there's nothing hidden from you, nothing magic that you just have to make assumptions about.

## Further reading

* [Introduction to JSON Web Tokens](https://jwt.io/introduction)
* [2 mins of HTTP](https://www.youtube.com/watch?v=Ic37FI351G4&list=PL6RpkC85SLQBCAZNbi-vNMSoXZJZp5wDq&index=1)
* [Shell parameter expansion](https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html) in Bash

---

If you finish earlier than your fellow participants, you might like to ponder these questions. There isn't always a single correct answer and there are no prizes - they're just to give you something else to think about.

1. In the HTTP response to the DELETE request, what was the status code, and are there any others that might be appropriate?
