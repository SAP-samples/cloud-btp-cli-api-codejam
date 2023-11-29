[![REUSE status](https://api.reuse.software/badge/github.com/SAP-samples/cloud-btp-cli-api-codejam)](https://api.reuse.software/info/github.com/SAP-samples/cloud-btp-cli-api-codejam)

# Hands-on with the btp CLI and APIs

## Description

This repository contains the material for the "Hands-on with the btp CLI and APIs" CodeJam, a CodeJam within the [SAP CodeJam BTP group](https://groups.community.sap.com/t5/sap-codejam-btp/gh-p/codejam-btp).

There's also an alternative [mini-workshop](https://github.com/SAP-samples/cloud-btp-cli-api-codejam/tree/mini-workshop) branch in this repository which is a vastly reduced version of this content, cut down to fit into an 80 minute workshop, originally for the UKISUG Connect 2022 event.

## Overview

This CodeJam is on the Core Service APIs for SAP BTP, which, [according to the SAP Business Accelerator Hub]([url](https://hub.sap.com/package/SAPCloudPlatformCoreServices/rest)), allows you to "manage, build, and extend the core capabilities of SAP BTP." It also covers the command line interface tool for SAP BTP, otherwise known as the btp CLI.

After completing this CodeJam, you will be familiar with how to use the btp CLI on the command line, and also in scripts. You'll have seen how to harness its power to view, administer and generally manage resources on SAP BTP. You'll also have a good understanding of what is possible with the APIs and how to use them.

Rather than skimming the surface of these two topics, you'll dive deep into how things work, and also understand how the two are strongly related. You'll get to understand how to get to the rich seam of data that the btp CLI and the core service APIs offer, taking your time with discovery, authentication, making calls and parsing the results.

## Session prerequisites

In order to get the most from this CodeJam, and to be able to work through the exercises, there are certain prerequisites that you must have set up before the day of the CodeJam.

The prerequisites are detailed in a separate [prerequisites](prerequisites.md) file. Please ensure you work through these before attending the CodeJam.

## Exercises

These are the exercises, each in their own directory, sometimes with supporting files and scripts. We will work through the exercises in the order shown here. From a session flow perspective, we are taking the "coordinated" approach:

The instructor will set you off on the first exercise, and that's the only one you should do; if you finish before others, there are some questions at the end of the exercise for you to ponder. Do not proceed to the next exercise until the instructor tells you to do so.

> The exercises are written in a conversational way; this is so that they have enough context and information to be completed outside the hands-on session itself. To help you navigate and find what you have to actually do next, there are pointers like this 👉 throughout that indicate the things you have to actually do (as opposed to just read for background information).

1. [Installing the btp CLI](exercises/01-installing/README.md)
1. [Authenticating and managing configuration](exercises/02-authenticating-and-configuration/README.md)
1. [Setting up autocomplete and initial account exploration](exercises/03-autocomplete-and-exploration/README.md)
1. [Retrieving and parsing JSON output](exercises/04-retrieving-parsing-json-output/README.md)
1. [Preparing to call a Core Services API](exercises/05-core-services-api-prep/README.md)
1. [Gathering required credentials for the API call](exercises/06-core-services-api-creds/README.md)
1. [Making the API call and understanding the results](exercises/07-core-services-api-call/README.md)
1. [More on GUIDs, and resource creation with the btp CLI](exercises/08-guids-and-resource-creation/README.md)
1. [Deleting resources with the API](exercises/09-deleting-resources-with-api/README.md)

## Scripts

There are a handful of scripts that are used and explored in this CodeJam, some of them are used in multiple exercises. To that end, they're collected together in a separate [scripts/](scripts/) directory and there are symbolic links pointing to them from the relevant exercise-specific directories where needed.

## Feedback

If you can spare a couple of minutes at the end of the session, please help the author improve for next time by providing some feedback.

Simply use this [Give Feedback](https://github.com/SAP-samples/cloud-btp-cli-api-codejam/issues/new?assignees=&labels=feedback&template=session-feedback-template.md&title=Session%20Feedback) link to create a special "feedback" issue, and follow the instructions in there.

Thank you!

## How to obtain support

Support for the content in this repository is available during the actual time of the CodeJam event for which this content has been designed.

## Further connections and information

Here are a few pointers to resources for further connections and information on the btp CLI:

* there's a wealth of information on the SAP Help Portal in the [Account Administration Using the SAP BTP Command Line Interface (btp CLI) [Feature Set B]](https://help.sap.com/products/BTP/65de2977205c403bbc107264b8eccf4b/7c6df2db6332419ea7a862191525377c.html?locale=en-US&version=Cloud) topic
* the playlist [The SAP btp CLI](https://www.youtube.com/playlist?list=PL6RpkC85SLQDXx827kdjKc6HRvdMRZ8P5) on the SAP Developers YouTube channel contains recordings of past live streams on the topic
* there's a [branch in the SAP Tech Bytes repo](https://github.com/SAP-samples/sap-tech-bytes/tree/2021-09-01-btp-cli) covering some basic aspects of the btp CLI
* The SAP Business Accelerator Hub is the central place for APIs in the SAP world, and there's a specific area for the [Core Services for SAP BTP](https://hub.sap.com/package/SAPCloudPlatformCoreServices/rest) API package.

## License

Copyright (c) 2022 SAP SE or an SAP affiliate company. All rights reserved. This project is licensed under the Apache Software License, version 2.0 except as noted otherwise in the [LICENSE](LICENSES/Apache-2.0.txt) file.
