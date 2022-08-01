# Cloning this repository into your App Studio Dev Space

These instructions describe how you can clone this repository into your App Studio Dev Space, to get access to resources (such as scripts) in the various exercise directories.

## Move into the `projects/` directory

👉 In a terminal in your Dev Space (open a new one if required with `Terminal -> New Terminal`) ensure you're in the `projects/` directory in your home directory; this is a directory that is pre-created when you set the Dev Space up.

```bash
cd $HOME/projects/
```

## Invoke the repository cloning operation

👉 Run the clone command for this repository:

```bash
git clone https://github.com/SAP-samples/cloud-btp-cli-api-codejam/
```

Here's a sample of what happens:

```
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

👉 At this point you may want to open your home directory in the Explorer (so you can look around at the directory structure and the files). Do this by using menu path `File -> Open...` and specifying the `user/` directory as shown:

![opening the user directory](assets/open-user-dir.png)

The Dev Space should restart and you should be able to explore the contents of this repository, and also the contents of your `.bashrc` file and `bin/` directory, for example. You can now explore the contents of the clone of this repo too.

👉 Don't forget to open up a new terminal in the restarted Dev Space so you can continue where you left off now, back in the exercise.
