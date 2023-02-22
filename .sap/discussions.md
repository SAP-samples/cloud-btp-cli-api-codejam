# Exercise 01

[Questions](../exercises/01-installing/README.md#questions):

_Expressing the individual locations within your `PATH` on separate lines was done using [Bash shell parameter expansion](https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html). Using other command line tools, how else might you do it?_

One way would be to use `tr`, like this:

```bash
echo $PATH | tr ':' '\n'
```

This is straightforward and preferred by some as easier to read. Of course, adopting the [UNIX philosophy](https://en.wikipedia.org/wiki/Unix_philosophy) here, like this specific example (where the value of the `PATH` environment variable is piped into the `tr` program) opens up other possibilities, depending on one's tool preference. For example, using `awk` is also possible:

```bash
echo $PATH | awk 'BEGIN {RS=":"} {print $1}'
```

_Is placing the `btp` executable within `$HOME/bin/` a good option? Will it still be there if you restart your Dev Space?_

Yes, it's a good option, for two reasons. One, it's common practice to use a user-local `bin/` directory for user specific executables, and you don't need root permissions to maintain files there. Two, this `$HOME/bin/` directory survives a Dev Space restart, meaning the contents will still be there. There are a few temporary user-specific directories that are cleared or removed entirely when a Dev Space is restarted. Putting the executable in one of those would not be a good idea of course.

_What help is available for the btp CLI on the command line? What does `btp help` show you?_

It gives an overview of the different types of commands and options, although it stops short of listing all the combinations of actions and objects.

_Why are there two entries in `$HOME/bin/` for the `btp` executable?_

One is the real executable, but with a full name which includes the version, and the other is a symbolic link, with the short `btp` name, pointing to it. This way you can download and manage different versions of the btp CLI in case you need to. It's a common pattern. Moreover, you can have the `btp` symbolic link always point to the version you want to use, and the fact that it has a generic name rather than a version specific one allows for writing more generic and stable scripts.

# Exercise 02

[Questions](../exercises/02-authenticating-and-configuration/README.md#questions):

_Why were you told to use single quotes when echoing text into the `.bashrc` file? What would have happened if you'd use double quotes?_

The command looked like this:

```bash
echo 'export BTP_CLIENTCONFIG=$HOME/.config/btp/config.json' >> $HOME/.bashrc
```

If double quotes (`"`) had been used instead of single quotes, i.e.

```bash
echo "export BTP_CLIENTCONFIG=$HOME/.config/btp/config.json" >> $HOME/.bashrc
```

then the value of `$HOME` within the double quotes would have been immediately substituted (via [Shell Parameter Expansion](https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html), so that this line would have been appended to the `.bashrc` file:

```bash
export BTP_CLIENTCONFIG=/home/user/.config/btp/config.json
```

That is actually fine, but it's better practice to retain the abstract nature of the `$HOME` parameter so that if it were to change, the line in `.bashrc` would still work.

Referring to `$HOME` in double quotes causes shell parameter expansion to happen, resulting in this. But if it occurs within single quotes, shell parameter expansion does not happen.

_Did you try to authenticate using Single Sign-On (SSO)? How did it work for you? What about from within a container?_

Most of the time, containers have no GUI. While they may have a text-only browser installed (such as `lynx` or `w3m`), the one in the container image for this CodeJam does not. And even if there were a text-only browser, many Web-based SSO solutions do not support them. So running `btp login --sso` will have resulted in an error like this, with a suggestion that the URL be opened manually:

```text
SAP BTP command line interface (client v2.33.0)

CLI server URL [https://cpcli.cf.eu10.hana.ondemand.com]>
Connecting to CLI server at https://cpcli.cf.eu10.hana.ondemand.com...

Failed to open web browser.
Please continue login at: https://cpcli.cf.eu10.hana.ondemand.com/login/v2.33.0/browser/7d42eb32-4c46-8753-95d32152a3f9 (or use Ctrl+C to abort)
```

Rather than encounter this error, one can use `--sso manual` to just directly and explicitly say "just give me a URL and I'll get there somehow".

# Exercise 03

[Questions](../exercises/03-autocomplete-and-exploration/README.md#questions):

_How would you discover or confirm that the shell you're actually using is indeed a Bash shell?_

Normally one would look at the value of the `SHELL` environment variable. Here's an example:

```text
user: user $ echo $SHELL
/bin/bash
```

Within a shell in a Dev Space in the SAP Business Application Studio, the value of the `SHELL` environment variable is `/bin/false`. This is a little unexpected, and is currently under discussion internally. As an alternative in this circumstance, you can always also look at the value of `$0`, which reflects the name of the executable of what you're currently within, i.e. the shell:

```text
user: user $ echo $0
bash
```

See [What is the meaning of $0 in the Bash shell](https://unix.stackexchange.com/q/280454/87597) for more information.

# Exercise 04

[Questions](../exercises/04-retrieving-parsing-json-output/README.md#questions):

_What UNIX tool might you use to parse out the individual column values, say, to identify the region and provider values, from the text output in Parsing the output?_

The classic answer here is to use a tool such as `cut` or `awk`.

Taking the output in question, i.e.

```text
ap21     cf-ap21       cloudfoundry   AZURE
us10     cf-us10       cloudfoundry   AWS
eu10     cf-eu10       cloudfoundry   AWS
```

Imagine also that this output is in a file called `regions.txt`. Imagine also that our task is to list just the data centers, i.e. `cf-ap21`, `cf-us10` and `cf-eu10`.

In a more natural UNIX context, this output would be separated with tabs, rather than multiple spaces. The `cut` command works more naturally with tabs as separators (or "delimiters"), so we'd have to clean up this output first before using `cut`, to de-duplicate the multiple spaces (with `tr`'s `-s` option) and then tell `cut` that the delimiter was a single space (with `-d' '`) rather than the default tab character:

```text
user: user $ < regions.txt tr -s ' ' | cut -d' ' -f 2
cf-ap21
cf-us10
cf-eu10
```

Alternatively one could use `awk`, which often just "does what you want" without you having to think about things too much, and is more forgiving of output like this. Here's an example of how one would extract the data center list with `awk`:

```text
user: user $ awk '{print $2}' regions.txt
cf-ap21
cf-us10
cf-eu10
```

_When working through the `jq` filter to list the available datacenter names, did you spot what the subtle difference were between the different outputs from `.`, `.["datacenters"]` and `.["datacenters"] | .[]`?_

This question is to draw attention to the importance of the data structures expressed in the JSON.

Essentially, the entire response is an object with a single property, where the key is `datacenters` and the value is an array. This can be seen with the `.` filter of course.

When the `.["datacenters"]` (or `.datacenters` for short) filter is used, the outermost object structure (`{...}`) is not included in the output, as we're now asking for the value of the property which has the given key ("datacenters"). This value is an array, which is why the output of this filter has `[...]` as its outermost structure.

Finally, when the previous filter is piped into `.[]`, i.e. `.["datacenters"] | .[]` (or `.datacenters[]` for short), we get two separate JSON values in the output, both of which are objects. Remember that jq's [array value iterator](https://stedolan.github.io/jq/manual/#Array/ObjectValueIterator:.%5B%5D), i.e. `.[]`, "explodes" the contents of an array into separate and independent values.

_Looking at the `jq` filter we used to get the number of data centers (`.datacenters|length`), what happens when you use the filter `.datacenters[]|length`, and can you figure out what that result is, and why it's given?_

This is all about the array object iterator again, to underline what it does. With `.datacenters|length`, the value of `.datacenters` is a single JSON value. Specifically, it's an array.

When an array is passed to `length`, the output is the number of elements in that array, naturally.

But remember that in `.datacenters[]|length`, we have the array object iterator again, which "explodes" the contents of the array, and passes each element downstream, through the subsequent pipe(s). So the effect is that each of the elements of the data centers array (each data center object, effectively) is passed through a pipe to `length`. And each time, it's not an array any more that finds its way to `length`, it's an object (each data center is represented by an object).

And when you ask for the `length` of an _object_ (as opposed to an array), you get the number of properties it has (i.e. the number of keys). And in each of the data center objects, there are 10 properties. Here's an example of one of them:

```json
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
}
```

That's why we get this contrast:

```text
user: user $ jq '.datacenters|length' regions.json
2
user: user $ jq '.datacenters[]|length' regions.json
10
10
```

_How might you explore JSON data sets further, and in a more interactive way? Here are some approaches: jqterm and jq play both of which are web-based, and ijq ("interactive jq") which is a terminal UI. For an example of "jq play", here's a shared snippet showing the execution of the CF data centers location list we looked at in this exercise. And for more on "interactive jq" you may wish to read Exploring JSON with interactive jq._

This question is just highlighting that there are different ways to use jq to explore data interactively, rather than just write jq filters just as you'd write code in any other programming language.

# Exercise 05

[Questions](../exercises/05-core-services-api-prep/README.md#questions):

_When listing the environment instances for the subaccount, how else might you make that btp CLI call, without using the `--subaccount` parameter?_

If you had previously used the `btp target` command to set the subaccount as a target, you would then no longer need to specify the subaccount explicitly in this (or other similar commands) with `--subaccount`.

_The embedded, stringified JSON values in the `parameters` and `labels` properties are a bit strange. Stranger still are the names of some the properties in that embedded JSON. Have you ever seen property names containing whitespace (`Org Name`, `API Endpoint`, `Org ID`)? Moreover, depending on the age of your environment instance, these property names may also contain colons :-) Why do you think they exist this way?_

There's no definitive answer, but a likely one is that they're generated automatically from another system and injected almost verbatim as the values of properties here. In order to be injected as simple values, rather than structures that would then be considered "foreign" and somewhat unexpected, the JSON values -- which are objects in both the `labels` and `parameters` cases -- are then just conveyed as scalars (strings, to be precise).

_What's the mechanism in the get_cf_api_endpoint script that defaults to "trial" as the name for the subaccount?_

It's in this line:

```bash
local displayname="${1:-trial}"
```

and specifically is the "${1:-trial}" part. This is parameter expansion in action, specifically the "parameter default" mechanism, that substitutes a value (`trial` here) if the parameter (`$1` here, i.e. the first value passed as an argument when the enclosing function was invoked) is not set. In order to use such an expansion mechanism, the expression must be enclosed in braces (`{...}`), and it's generally [good practice](https://www.shellcheck.net/wiki/SC2086) to use double quotes to prevent globbing and word splitting.


