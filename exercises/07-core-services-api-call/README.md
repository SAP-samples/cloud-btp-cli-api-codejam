# Exercise 07 - Making the API call

We've finally made it to the stage where we can make the call!

The journey so far has been deliberately focused on the details that we need to pay attention to, so we understand what we're doing when we have to create a service key and make an OAuth 2.0 call to get an access token. Now we have that token, let's use it!

## Final preparation

We know that we want to make a call to the one endpoint in the Regions for Global Account group in the Entitlements Service API, i.e. to:

```text
/entitlements/v1/globalAccountAllowedDataCenters
```

and that we have an access token obtained through a successful completion of the OAuth 2.0 Resource Owner Password Credentials ("Password") flow.

The result of that process has left us with two files, both of which we still need.

|File|Content|What we need|
|-|-|-|
|`cis-central-sk.json`|Service key data|The Entitlements Service API base URL in `endpoints.entitlements_service_url`|
|`tokendata.json`|OAuth 2.0 data|The access token in `access_token`|

With your new `jq` filtering skills, tease out these two values to have a look at them.

👉 First, have a look at the base URL:

```bash
jq --raw-output .endpoints.entitlements_service_url cis-central-sk.json
```

You should see something like this:

```text
https://entitlements-service.cfapps.eu10.hana.ondemand.com
```

👉 Now have a quick look at the access token; use `jq`'s [string slice](https://stedolan.github.io/jq/manual/#Array/StringSlice:.[10:15]) to only return a portion of it, because you don't need to see all of it, and it's better for security:

```bash
jq --raw-output '.access_token[:50]' tokendata.json
```

You should see something like this:

```text
eyJhbGciOiJSUzI1NiIsImprdSI6Imh0dHBzOi8vOGZlN2VmZD
```

## Make the call

You now have everything you need to make the call to the API endpoint. The data is just a single, simple HTTP call away.

Let's do it manually first, with `curl`. In contrast to the HTTP call we made in the previous exercise, there is only one header that we need to have sent in the request, explicitly (there will be other headers sent by `curl` automatically).

👉 Execute this `curl` request:

```bash
curl \
  --url "$(jq -r .endpoints.entitlements_service_url cis-central-sk.json)" \
  --header "Authorization: Bearer $(jq -r .access_token tokendata.json)"
```

> In the `curl` invocation in the previous exercise, we saw (using the `--verbose` option) something like this in the output: `> Authorization: Basic c2ItdXQtZTQ4ZDQ5N2UtMWI4MS00...==`.
>
> This is a Basic Authentication HTTP header that was created automatically by `curl` as a result of the `--user` option, and the content following the authorization scheme name ("Basic") is a combination of the username and password (joined with a colon) and then encoded with base64.
>
> In this `curl` invocation we're making now, we cannot use Basic Authentication because our request would be rejected as the server does not accept that sort of authorization. Instead, we need to use a Bearer token authorization scheme, which consists of the scheme name "Bearer" followed by ... you guessed it, our access token.
>
> In case you're wondering, the `$(...)` construction used in this header (as well as in the `--url` option) is command substitution in Bash, i.e. whatever is within the brackets is executed and then the output of that is substituted. So in this case we get the access token value.
>
> See the [Further reading](#further-reading) section at the end of this exercise for links to more information on these topics.

The simple script [call-entitlements-service-regions-api](call-entitlements-service-regions-api), also in this directory, will help you do this. Like the `generate-password-grant-type` script, it also requires the service key JSON data file (so it can retrieve the value of the `entitlements_service_url` endpoint) ... it also requires the name of the token data JSON file.

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

* The [Authorization](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Authorization) page helps us understand the HTTP Authorization header syntax
* The [HTTP Authentication](https://developer.mozilla.org/en-US/docs/Web/HTTP/Authentication#basic_authentication_scheme) page has information on the [Basic authentication scheme](https://developer.mozilla.org/en-US/docs/Web/HTTP/Authentication#basic_authentication_scheme)
* On token-based [bearer authentication](https://swagger.io/docs/specification/authentication/bearer-authentication/)
* Bash [command substitution](https://www.gnu.org/software/bash/manual/html_node/Command-Substitution.html)

---

If you finish earlier than your fellow participants, you might like to ponder these questions. There isn't always a single correct answer and there are no prizes - they're just to give you something else to think about.

1. Take a look at the token data you retrieved - what's the lifetime of the access token, in hours?
1. Have a bit of a stare at the [call-entitlements-service-regions-api](call-entitlements-service-regions-api) script, and the associated [lib.sh](lib.sh) library. Is there anything in there that you'd like to know more about?