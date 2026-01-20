# Description

Fly WorkSpaces is a web service you can run on [fly.io](https://fly.io) that will provision [code-server](https://github.com/coder/code-server) instances onto [Sprites](https://sprites.dev).

This is a work in progress, feedback and contributions are welcome!


# Installation

First, launch Fly-Mojo-Base by running `cd Fly-Mojo-Base` and then `fly launch --ha=false`.  This will create a base image with the dependencies for the project.  See Fly's documentation for [using base images for faster deployments]( https://fly.io/docs/blueprints/using-base-images-for-faster-deployments/) for more information on this technique.

You can get the URL for your base image by running `fly releases --image` in that directory.

Copy the `DOCKER IMAGE` URL and update the `../src/Dockerfile` file to use this as the `FROM` line.

Now enter the src directory with `cd ../src`.

Run `fly launch` to configure the application.

You will need a Sprites API key as well as two databases.  You can create an [MPG cluster](https://fly.io/docs/mpg/) and then create a user account `workspace` and two databases: `minion` and `workspace`.  Use the `connections` tab to get the `postgresql://` connection lines.

Set the secrets:

```
fly secrets set MINION_DATABASE="your postgresql:// connection line for the minion database."
fly secrets set WORKSPACE_DATABASE="your postgresql:// connection line for the workspace database."
fly secrets set SPRITES_API_KEY="your sprites API key"
```

The application should be running now and have connections to the databases and sprites API.


# Adding A User Account

You'll need to add a user account to login.  Get a shell to one of the machines with `fly ssh console --machine <machine_id>`, then `su app`.

You'll `cd /home/app/src/Web` and run `./script/fly_work_space create-user --help` to see how to create a user.

Once you have a user set, you can login and begin creating workspaces!


