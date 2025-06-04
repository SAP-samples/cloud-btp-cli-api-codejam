# Cloning this repository into your working environment

These instructions describe how you can clone this repository into your working environment, whether that's an SAP Business Application Studio Dev Space, or a container. Cloning the repository will allow you to get at resources (such as scripts) in the various exercise directories.

In a Dev Space there are different ways you can clone git repositories, including a convenient GUI wizard to do so. But in this case, we're just going to use the most straightforward way, and one that is the same whether you're using a Dev Space or in another context (such as a container running a Bash shell) - on the command line.

## Move into the `projects/` directory

👉 In your current shell session, move to the `projects/` directory in your home directory; this is a directory that should already exist.

```bash
cd $HOME/projects/
```

## Invoke the repository cloning operation

👉 Run the clone command for this repository:

```bash
git clone https://github.com/SAP-samples/cloud-btp-cli-api-codejam/
```

Here's a sample of what happens:

```text
user: projects $ git clone https://github.com/SAP-samples/cloud-btp-cli-api-codejam/
Cloning into 'cloud-btp-cli-api-codejam'...
remote: Enumerating objects: 329, done.
remote: Counting objects: 100% (22/22), done.
remote: Compressing objects: 100% (15/15), done.
remote: Total 329 (delta 11), reused 13 (delta 7), pack-reused 307
Receiving objects: 100% (329/329), 6.90 MiB | 17.85 MiB/s, done.
Resolving deltas: 100% (170/170), done.
```

At this point, you have a new directory `cloud-btp-cli-api-codejam`.

## Open your home directory in the Explorer

> This section is only relevant for those working through this CodeJam in a Dev Space in the SAP Business Application Studio.

👉 At this point you may want to open your home directory in the Explorer (so you can look around at the directory structure and the files). Do this by using menu path `File -> Open Folder...` and specifying the `/home/user/` directory as shown:

![opening the user directory](assets/open-user-dir.png)

The Dev Space should restart and you should be able to explore the contents of this repository, and also the contents of your `.bashrc` file and `bin/` directory, for example. You can now explore the contents of the clone of this repo too.
