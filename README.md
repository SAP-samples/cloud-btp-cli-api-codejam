[![REUSE status](https://api.reuse.software/badge/github.com/SAP-samples/cloud-btp-cli-api-codejam)](https://api.reuse.software/info/github.com/SAP-samples/cloud-btp-cli-api-codejam)

# Hands-on with the btp CLI and APIs

## Description

This repository, specifically the [main branch](https://github.com/SAP-samples/cloud-btp-cli-api-codejam), contains the material for the "Hands-on with the btp CLI and APIs" CodeJam, a CodeJam within the [SAP CodeJam BTP group](https://groups.community.sap.com/t5/sap-codejam-btp/gh-p/codejam-btp).

This particular `mini-workshop` branch of the repository is a heavily reduced version of that material, to fit within the time constraints of a 80 minute mini workshop at the [UK & Ireland SAP User Group (UKISUG) Connect 2022](https://eu.eventscloud.com/ehome/ukisugconnect2022/200545487/) event.

## Overview

This mini workshop introduces attendees to `btp`, the CLI for the SAP Business Technology Platform (SAP BTP). Here's the description of the btp CLI from the [official download page](https://tools.hana.ondemand.com/#cloud): "_Use the btp CLI for account administration on SAP BTP. The btp CLI is only available for global accounts on feature set B (for example, SAP BTP Trial accounts)_".

It also introduces attendees to the APIs for SAP BTP, the Core Services for SAP BTP, which, [according to the SAP API Business Hub](https://api.sap.com/package/SAPCloudPlatformCoreServices/rest), allow you to "_manage, build, and extend the core capabilities of SAP BTP._"

## About this mini workshop

In this mini workshop you'll get some first hand experience using the btp CLI, and will also find, prepare for and make a call to one of the APIs for SAP BTP.

## Session prerequisites

In order to get the most from this mini workshop, and to be able to work through the exercises, there are certain prerequisites that you must have set up before the day of the event.

The prerequisites are detailed in a separate [prerequisites](prerequisites.md) file. Please ensure you work through these before attending; the UKISUG Connect 2022 organizers should have sent you this information in advance. 

> Due to time constraints, we'll all be using Dev Spaces in your own trial subscriptions to SAP Business Application Studio, rather than explore the Docker container based approach.

## Exercises

These are the exercises, each in their own directory, sometimes with supporting files and scripts. We will work through the exercises in the order shown here. From a session flow perspective, we are taking the "coordinated" approach:

The instructor will set you off on the first exercise, and that's the only one you should do; if you finish before others, there are some questions at the end of the exercise for you to ponder. Do not proceed to the next exercise until the instructor tells you to do so.

> The exercises are written in a conversational way; this is so that they have enough context and information to be completed outside the hands-on session itself. To help you navigate and find what you have to actually do next, there are pointers like this 👉 throughout that indicate the things you have to actually do (as opposed to just read for background information).

1. [Getting set up and installing the btp CLI](exercises/01-installing/README.md)
1. [Authenticating and targeting a subaccount](exercises/02-authenticating-and-configuration/README.md)
1. [Setting up autocomplete and initial account exploration](exercises/03-autocomplete-and-exploration/README.md)
1. [Retrieving and parsing JSON output](exercises/04-retrieving-parsing-json-output/README.md)
1. [Preparing to call a Core Services API](exercises/05-core-services-api-prep/README.md)
1. [Gathering required credentials for the API call](exercises/06-core-services-api-creds/README.md)
1. [Making the API call and understanding the results](exercises/07-core-services-api-call/README.md)

## Scripts

There are a handful of scripts that are used and explored in this mini workshop, some of them are used in multiple exercises. To that end, they're collected together in a separate [scripts/](scripts/) directory and there are symbolic links pointing to them from the relevant exercise-specific directories where needed.

## How to obtain support

Support for the content in this repository is available during the actual time of the mini workshop event for which this content has been designed.

## Further connections and information

Here are a few pointers to resources for further connections and information on the btp CLI:

* there's a wealth of information on the SAP Help Portal in the [Account Administration Using the SAP BTP Command Line Interface (btp CLI) [Feature Set B]](https://help.sap.com/products/BTP/65de2977205c403bbc107264b8eccf4b/7c6df2db6332419ea7a862191525377c.html?locale=en-US&version=Cloud) topic
* the playlist [The SAP btp CLI](https://www.youtube.com/playlist?list=PL6RpkC85SLQDXx827kdjKc6HRvdMRZ8P5) on the SAP Developers YouTube channel contains recordings of past live streams on the topic
* there's a [branch in the SAP Tech Bytes repo](https://github.com/SAP-samples/sap-tech-bytes/tree/2021-09-01-btp-cli) covering some basic aspects of the btp CLI
* The SAP API Business Hub is the central place for APIs in the SAP world, and there's a specific area for the [Core Services for SAP BTP](https://api.sap.com/package/SAPCloudPlatformCoreServices/rest) API package.

## License

Copyright (c) 2022 SAP SE or an SAP affiliate company. All rights reserved. This project is licensed under the Apache Software License, version 2.0 except as noted otherwise in the [LICENSE](LICENSES/Apache-2.0.txt) file.
