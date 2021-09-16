# Lab 1: Setup Codespaces Lab

## Lab Resources

- For these labs, we will be using [GitHub Codespaces](https://github.com/features/codespaces)
- [Docs](https://docs.github.com/en/codespaces) for Codespaces

## Open a Codespace

- Navigate to the [k8s-quickstart](https://github.com/cse-labs/k8s-quickstart) repo
- Click the green `Code` button
- Select the `Codespaces` tab in the dropdown
- Click `New codespace`

## Verify Codespace

Validate docker is running

```bash
docker -v
```

Validate k3d was installed

```bash
k3d --version
```

## Stop a Codespace

> Codespaces will automatically stop after 30 minutes of inactivity. Slated to be configurable in the future.

To manually stop Codespaces

- On the lower left corner, select `Codespaces`

- A dropdown will appear at the top of the screen. Select `Stop Current Codespace`

## Restart a Codespace

To restart a Codespace from the GitHub Repo

- Navigate to the [k8s-quickstart](https://github.com/cse-labs/k8s-quickstart) repo
- Click the green `Code` button
- Select the `Codespaces` tab in the dropdown
- Select previously created Codespace

To restart a Codespace from [Your Codespaces](https://github.com/codespaces)

- To the right of the Codespaces you'd like to restart, click the 3 dots (•••)
- From the dropdown, select `Open in browser`

## Delete a Codespace

To delete a Codespace from [Your Codespaces](https://github.com/codespaces)

- To the right of the Codespace you'd like to delete, click the 3 dots (•••)
- From the dropdown, select `Delete`

## .devcontainer/devcontainer.json

The `devcontainer.json` provides instructions on setting up codespace.

- References the [Dockerfile](#dockerfile) which contains the image's registry used in the codespace container
- Setup a minimum cores requirement when a user starts a codespace
- Exposes ports external to the container via `forwardPorts` and labels them in the `Ports` tab via `portsAttributes`
- Installs VSCode extensions
  - `humao.rest-client` provides an easy way to send requests ([Example](../curl.http))
- References [lifecycle scripts](#lifecycle-scripts) that will execute at certain points when codespaces start

## .devcontainer/Dockerfile

The base image for this codespace is `ghcr.io/cse-labs/k3d`. It is built on a weekly cadance thanks to [GitHub Workflow](https://github.com/cse-labs/codespaces-images/blob/main/.github/workflows/build-images.yaml). A [Dockerfile](https://github.com/cse-labs/codespaces-images/blob/main/Dockerfile) contains the instructions for building images.

## Lifecycle Scripts

This codespace utilizes 3 lifecycle commands

- onCreateCommand
  - Runs once on container creation
  - Where we clone repos and make changes to file/folder structures
- postCreateCommand
  - Runs once after container creation
  - Runs in background after UI is available
  - Where we upgrade packages and add additional commands
- postStartCommand
  - Runs in background after each time the container starts
  - Where we keep the base docker images used in our [deploy yamls](../deploy)

We add logging to the scripts and keep the output in `~/status
