# Exercise 04 - Retrieving and parsing JSON output

At the end of this exercise, you'll know how to get the btp CLI to give you a more predictable and machine-readable output, which is especially helpful for combining the use of the btp CLI into automation and other scripts.

We'll retrieve information about the regions in which subaccounts can be created.

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

Traditional Unix commands output only the data requested, often with no frills. This is so the output, that often gets piped into a subsequent command, can be processed without issue. What you might want if you were intending to write a script to examine the possible regions and make a decision based upon what was available, is just the basic output:

```
ap21     cf-ap21       cloudfoundry   AZURE
us10     cf-us10       cloudfoundry   AWS
eu10     cf-eu10       cloudfoundry   AWS
```

In other words, this minimal output does not have the "Showing available regions..." message, the "OK" or any of the multiple blank lines we see in the previous output.

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
user: user $ btp list accounts/available-region 2> /dev/null | grep -E '^[a-z]{2}[0-9]+\s+'
ap21     cf-ap21       cloudfoundry   AZURE
us10     cf-us10       cloudfoundry   AWS
eu10     cf-eu10       cloudfoundry   AWS
user: user $
```

> The redirection of STDERR (with `2>`) to `/dev/null` in both of these examples is to get rid of the "OK" part of the result (and two of the blank lines), all of which are currently emitted to that error file descriptor.

These and many more approaches do the job, but they are somewhat brittle and depend on the data and the output. The challenge with each of the above two (deliberately simple) approaches are:

* the `sed` based solution relies on the "region" heading
* the `grep` based solution assumes the region identifiers are two lowercase letters followed by at least one digit, then some whitespace

## Use the JSON format output option

Some more recent command line tools deal with resources that are structured in ways that are sometimes too complex to be represented in plain text. The [JSON](https://en.wikipedia.org/wiki/JSON) format is commonly used to express more structured data, and is often used as an alternative output format for commands.

JSON output is a more convenient way to convey structure, and can be parsed more reliably. JSON output is available from the btp CLI via the `--format json` option. The JSON output is more predictable and the team's aim is to keep it as stable as possible.

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

> You'll also an "OK" surrounded by blank lines, but this is again sent to STDERR. From now on the executable examples will include redirecting STDERR to `/dev/null` to avoid the empty lines and "OK" - but bear in mind this is an extreme workaround because it would prevent any real errors from being displayed. This "OK" item output is being discussed internally.

### Parsing JSON output the wrong way

With the JSON output above, you might be tempted to parse the datacenter information as plain text, as the JSON appears naturally pretty-printed with property & value pairs on separate lines. Here's an example of that:

```
$ btp --format json list accounts/available-region | grep displayName
      "displayName": "Singapore - Azure",
      "displayName": "US East (VA) - AWS",
      "displayName": "Europe (Frankfurt) - AWS",
      ...
```

DO NOT DO THIS.

JSON is not a plain text format, and while the structure and information in a JSON response is predictable and parseable, the whitespace is not predictable.

The JSON output (taking the datacenter information we've seen already) could just as easily appear like this:

```
{"datacenters":[{"name":"cf-ap21","displayName":"Singapore - Azure","region":"ap21","environment":"c
loudfoundry","iaasProvider":"AZURE","supportsTrial":true,"provisioningServiceUrl":"https://provision
ing-service.cfapps.ap21.hana.ondemand.com","saasRegistryServiceUrl":"https://saas-manager.cfapps.ap2
1.hana.ondemand.com","domain":"ap21.hana.ondemand.com","geoAccess":"BACKWARD_COMPLIANT_EU_ACCESS"},{
"name":"cf-us10","displayName":"US East (VA) - AWS","region":"us10","environment":"cloudfoundry","ia
asProvider":"AWS","supportsTrial":true,"provisioningServiceUrl":"https://provisioning-service.cfapps
.us10.hana.ondemand.com","saasRegistryServiceUrl":"https://saas-manager.cfapps.us10.hana.ondemand.co
m","domain":"us10.hana.ondemand.com","geoAccess":"BACKWARD_COMPLIANT_EU_ACCESS"},{"name":"cf-eu10","
displayName":"Europe (Frankfurt) - AWS","region":"eu10","environment":"cloudfoundry","iaasProvider":
"AWS","supportsTrial":false,"provisioningServiceUrl":"https://provisioning-service.cfapps.eu10.hana.
```

Note that there wouldn't be the hard line breaks you see here (which are just so the data fits on the page width-wise) ... but any whitespace we saw earlier wouldn't be there either.

Try getting any sensible output from that using `grep` now!

> If you're curious, this dense output was produced using normal Unix commands: `btp --format json list accounts/available-region | jq -c . | fold -w100 | head`.

### Parsing JSON output the right way

Parsing JSON with the right tool is essential. Happily, it's also straightforward and can be very powerful and flexible.

One tool that is popular for this is [jq](https://stedolan.github.io/jq/), which is described as "a lightweight and flexible command-line JSON processor". It supports an entire language [which is Turing complete](https://github.com/MakeNowJust/bf.jq) but is readily useful at a simple level too. Your App Studio Dev Space comes already equipped with `jq` so you can try it out now.

#### Listing the available datacenter names

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

Here's a brief explanation of the `jq` invocation. It's worth mentioning in passing that the collection of language elements passed to `jq` itself is often referred to as a "filter", as are the component parts too.

It will help to stare at this filter for a few minutes:

```jq
.datacenters[].displayName
```

Let's start by rewriting it in a more verbose way so we can identify and understand the parts:

```jq
.["datacenters"] | .[] | .["displayName"]
```
The pipeline concept you may already know from the shell is also a core part of `jq`. This is what the `|` symbols are for.

1. The filter starts with the simplest construct, which is the [identity](https://stedolan.github.io/jq/manual/#Identity:.) `.`. This says "everything that you have right now", which at the start is all of the JSON.

1. This is combined with a [generic object index](https://stedolan.github.io/jq/manual/#GenericObjectIndex:.[%3Cstring%3E]) to give `.["datacenters"]` which is a reference to the value of the `datacenters` property. From the output earlier, we know that this is an array (a list of objects, each one representing the detail of a data center).

1. So the result of this first part, before the first pipe (`|`), is the array of data centers. This is then piped into the next part.

1. And the next part, which looks like this `.[]`, is the [array value iterator](https://stedolan.github.io/jq/manual/#Array/ObjectValueIterator:.[]) which explodes all of the elements of the incoming array (the `.` in the `.[]` component here refers now to what was passed in through the pipe) and sends each of them downstream.

1. This means that each of the elements (each of the objects representing a data center) is passed into the next pipe that sends the data to the final component of the filter, which is another object index `.["displayName"]`, which just picks out and emits the value of the `displayName` property. Because this component of the filter is invoked once per array element, we get an entire list of data center display names as the output. And of course this time, the `.` in the `.["displayName"]` construct refers to whatever was passed in through the pipe, which (for each and every one of the multiple invocations) is an object, one of the elements of the `datacenters` array.

These examples of the generic object index can be shortened from e.g. `.["datacenters"]` to `.datacenters` which is known as a [object identifier-index](https://stedolan.github.io/jq/manual/#ObjectIdentifier-Index:.foo,.foo.bar). This gives us:

```jq
.datacenters | .[] | .displayName
```

Moreover, the array value iterator `.[]` can be combined also with what it operates upon (the `.datacenters` object identifier-index), giving us:

```jq
.datacenters[] | .displayName
```

Finally, object identifier-index values can be concatenated too, giving us this:

```jq
.datacenters[].displayName
```

Before we finish this exercise, let's gently explore `jq` a little more.

#### Counting the total number of data centers

Now we have an understanding of what `.datacenters` gives us, we can combine that knowledge with the [length](https://stedolan.github.io/jq/manual/#length) function to get a count of elements:

👉 Modify the previous command to supply `jq` with a different filter, thus:

```bash
btp --format json list accounts/available-region 2> /dev/null \
    | jq '.datacenters|length'
```

This should produce a single scalar value as output, like this (with the value reflecting the number of elements in your array of data centers):

```
3
```

Although not important here, this value is in fact valid JSON too.

#### Being nice to the btp CLI endpoint

👉 Before we continue, let's be nice to the btp CLI endpoint being called, and cache the results of the list of available regions in a temporary file:

```bash
btp --format json list accounts/available-region 2> /dev/null \
    > regions.json
```

Now we can use this file like this:

```bash
jq '.datacenters|length' regions.json
```

#### Listing the locations of the CF data centers

What if we wanted to list only those data centers that were Cloud Foundry based, and get their geographic region, which is shown as part of the display name string (they look like this: "US East (VA) - AWS")?

We can use `jq`'s [select](https://stedolan.github.io/jq/manual/#select(boolean_expression)) function to pick elements from a list, and a couple of other functions for some simple string manipulation.

👉 Try this; it's a little longer than the previous filter, so it's presented across multiple lines for readability, but because of the beauty of the shell, you can still copy and paste it in as-is:

```bash
jq --raw-output '
  .datacenters[]
  | select(.environment == "cloudfoundry")
  | .displayName
  | split(" - ")
  | first
' regions.json
```

Based on the data center data above, this is the output produced:

```
Singapore
US East (VA)
Europe (Frankfurt)
```

Here are a few notes to help you as you [stare](https://qmacro.org/blog/posts/2017/02/19/the-beauty-of-recursion-and-list-machinery/#initialrecognition) at this filter invocation:

* the `--raw-output` option (which can be expressed as `-r` too) tells `jq` to not output strings as JSON strings, i.e. not to put them in double quotes
* using [select](https://stedolan.github.io/jq/manual/#select(boolean_expression)) can be used to filter out (or keep) data according to a boolean expression; in this case data will be kept (passed through to the next part, rather than thrown away) if the value of the `environment` property is "cloudfoundry"
* for those data center objects that are kept (passed through), we then select just the value for the `displayName` property
* and then use [split](https://stedolan.github.io/jq/manual/#split(str)) with the " - " value to divide the value up into two parts which are emitted as elements of an array
* and finally that array is passed to [first](https://stedolan.github.io/jq/manual/#first,last,nth(n)) which (as you might guess) returns just the first element

> In case you're curious, `first` is actually just syntactic sugar for the 0th form of the [array index](https://stedolan.github.io/jq/manual/#ArrayIndex:.[2]); you can see the definition of `first` in the `jq` sources: [`def first: .[0];`](https://github.com/stedolan/jq/blob/a9f97e9e61a910a374a5d768244e8ad63f407d3e/src/builtin.jq#L187)

#### Counting the data centers by hyperscaler

Here's a final example for that introduces a couple more important `jq` functions [to_entries](https://stedolan.github.io/jq/manual/#to_entries,from_entries,with_entries) and [group_by](https://stedolan.github.io/jq/manual/#group_by(path_expression)), and the [array construction](https://stedolan.github.io/jq/manual/#Arrayconstruction:[]) mechanism (`[...]`).

Let's say we wanted to see how many data centers were available, by hyperscaler?

👉 Try this:

```bash
jq --raw-output '
  .datacenters
  | to_entries
  | group_by(.value.iaasProvider)[]
  | [first.value.iaasProvider, length]
  | @csv
' regions.json
```

> The `@csv` is a format string that will produce valid and reliable CSV output from arrays

## Summary

At this point you know how to get the btp CLI to output the structured data in a more machine-parseable format, and what you can do with that format.

## Further reading

* A quick [overview of JSON](https://www.json.org/json-en.html)
* The [jq manual](https://stedolan.github.io/jq/manual/)
* [Various posts about jq on qmacro.org](https://qmacro.org/tags/jq/)

---

If you finish earlier than your fellow participants, you might like to ponder these questions. There isn't always a single correct answer and there are no prizes - they're just to give you something else to think about.

1. What Unix tool might you use to parse out the individual column values, say, to identify the region and provider values, from the text output in [Parsing the output](#parsing-the-output)?

1. Looking at the `jq` filter we used to get the number of data centers (`.datacenters|length`), what happens when you use the filter `.datacenters[]|length`, and can you figure out what that result is, and why it's given?

1. How might you explore JSON data sets further, and in a more interactive way? There are two main options: [jq play](https://jqplay.org/) which is web-based, and [ijq](https://sr.ht/~gpanders/ijq/) ("interactive jq") which is a terminal UI. For an example of "jq play", here's a [shared snippet](https://jqplay.org/s/14QVt1q2o09) showing the execution of the CF data centers location list we looked at in this exercise. And for more on "interactive jq" you may wish to read [Exploring JSON with interactive jq](https://qmacro.org/blog/posts/2022/05/21/exploring-json-with-interactive-jq/).
