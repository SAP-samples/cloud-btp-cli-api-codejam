# Exercise 05 - Preparing to call a Core Services API

The btp CLI implementation has a client / server nature. The server component facilitates calls to APIs in the [Core Services for SAP BTP](https://api.sap.com/package/SAPCloudPlatformCoreServices/rest) package. So the btp CLI effectively gives you a comfortable way of consuming those APIs that are specifically designed to let you "manage, build, and extend the core capabilities of SAP BTP".

During the course of this and also the subsequent exercise you'll see that first hand, by observing that the JSON you saw in the previous exercise (emitted from `btp --format json list accounts/available-region`) is effectively the same as the output from a call to the corresponding API endpoint.

While the process of calling an API is not complicated, there are some moving parts that work together are important for us to thoroughly understand. We'll do that together by taking a steady journey through those moving parts, with enough time to reflect and get things straight in our minds.

In this exercise, you'll do some preparatory work that's required. In the next exercise, you'll use the information gained in this exercise (mostly the CF API endpoint that you need) to obtain credentials for the call. And in the exercise that follows that, you'll use those credentials to make the call and then examine the output.

Ready?

## Learning about the API structure, authentication and use

The endpoint in question lives within the [Entitlements Service](https://api.sap.com/api/APIEntitlementsService/overview) API, specifically within the "Regions for Global Account" group. You can see this in the SAP API Business Hub:

![Regions for Global Account endpoint](assets/regions-for-global-account.png)

It's worth pausing a second to think about how APIs are organized on the SAP API Business Hub. There are API packages, APIs, and endpoints that are collected into groups. The hierarchy is as follows, showing where this endpoint is:

```text
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

### Credentials for API calls

The API endpoints are protected, and calls to them require credentials. For OAuth 2.0 protected resources, these credentials are usually in the form of access tokens, long opaque strings of characters. In general, obtaining an access token involves using information related to an instance of a service (on SAP BTP) to which the API relates. This information is contained in a binding (also known as a service key in Cloud Foundry contexts).

So to get to the stage where an access token is obtained, this is the general approach:

1. An instance of a service is created
1. When creating a service instance, a plan for that service must be specified
1. From the instance, a binding is then created
1. Using information in this binding, an access token is then requested

There are different flows, also known as "grant types", that describe how the access token request is made. Once the access token is received, it can be used to authenticate the API call.

While we're in the mood for ASCII art, here's that in diagram form:

```text
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

### Understanding what's required for a token request

We're eventually (in a subsequent exercise) going to make a call to the one endpoint in the Regions for Global Account group, i.e. to:

```text
/entitlements/v1/globalAccountAllowedDataCenters
```

The endpoints in the Entitlement Service API are protected by the OAuth 2.0 "Resource Owner Password Credentials" grant type, otherwise known as the "Password" grant type (this grant type is considered legacy, but is still used to protect some resources in this area). See the link to understanding OAuth 2.0 grant types in the [Further reading](#further-reading) section below for more background information.

👉 Head over to the [Entitlements Service API overview](https://api.sap.com/api/APIEntitlementsService/overview) page on the SAP API Business Hub.

👉 Find and follow the link, under the Documentation heading, to the [Account Administration Using APIs of the SAP Cloud Management Service](https://help.sap.com/docs/BTP/65de2977205c403bbc107264b8eccf4b/17b6a171552544a6804f12ea83112a3f.html?locale=en-US) section in the SAP Help Portal, where you'll see something like this:

![Account Administration documentation page](assets/account-admin-docu-page.png)

👉 Explore the two nodes highlighted in red, to see that it's the "SAP Cloud Management" service that is relevant here, and that the technical name for this service is `cis`. See also that there are two plans for the SAP Cloud Management service: `central` and `local`.

The `central` plan affords a little more access than the `local` plan so we'll go for the `central` plan. This is where these values fit into our diagram:

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

There are different places that a service instance can be created, but [as you have a Cloud Foundry environment set up](../../prerequisites.md#subaccount-and-cloud-foundry-environment), we'll use that.

## Determining your CF API endpoint

So the choice of Cloud Foundry (CF) as an environment for the service instance means that, in a similar way to how we logged in with the btp CLI, we now must log in with the CF CLI, `cf`, so that we can use that tool to create the service instance.

To log in, this we need to know which endpoint we must connect to, as we'll need to specify it like this:

```bash
cf login -a <API endpoint URL>
```

In [the longer (CodeJam) version of this mini-workshop](https://github.com/SAP-samples/cloud-btp-cli-api-codejam/tree/mini-workshop), this [equivalent section on determining your CF API endpoint](https://github.com/SAP-samples/cloud-btp-cli-api-codejam/blob/main/exercises/05-core-services-api-prep/README.md#determining-your-cf-api-endpoint) is an in-depth journey into mechanically determining that value. This is so you can understand where that value comes from, where it's available, and how to get at it in an automated scenario.

But owing to the restricted time we have for this mini workshop, we can just look in the BTP Cockpit for the URL, where it's shown as the value for "API Endpoint" in the "Cloud Foundry Environment" section.

![API endpoint visible in the BTP cockpit](assets/api-endpoint-in-cockpit.png)

Do that now, and note down the value. It will be something similar to what you see in the screenshot (the "region" portion of the name may be different):

```text
https://api.cf.eu10.hana.ondemand.com
```

## Summary

At this point you have gained some experience in understanding and parsing the JSON data that is available from various btp CLI commands, relating to your SAP BTP subaccount and CF environment instance. You have now added `ijq` to your toolset, which is a helpful way of building `jq` filters interactively, as well as exploring JSON.
At this point you know what you need from an API call perspective in terms of the CF service and plan, and have what you need to authenticate with the `cf` CLI, which you'll need to do in order to create a service instance.

## Further reading

* [Understanding OAuth 2.0 grant types](https://github.com/SAP-archive/cloud-apis-virtual-event/tree/main/exercises/02#3-understand-oauth-20-grant-types)
* [Getting an Access Token for SAP Cloud Management Service APIs](https://help.sap.com/products/BTP/65de2977205c403bbc107264b8eccf4b/3670474a58c24ac2b082e76cbbd9dc19.html?locale=en-US)

---

If you finish earlier than your fellow participants, you might like to ponder these questions. There isn't always a single correct answer and there are no prizes - they're just to give you something else to think about.

1. There's a script in this exercise directory that will do this discovery mechanically, in a way that's [described in the longer CodeJam version of this exercise](https://github.com/SAP-samples/cloud-btp-cli-api-codejam/blob/main/exercises/05-core-services-api-prep/README.md#determining-your-cf-api-endpoint). It's called [get_cf_api_endpoint](get_cf_api_endpoint). Have a look at it in the editor and see what you can make of it. Do you have any questions? Try to run it and see what it does:

  ```bash
  cd $HOME/projects/cloud-btp-cli-api-codejam/exercises/05-core-services-api-prep/
  ./get_cf_api_endpoint
  ```
