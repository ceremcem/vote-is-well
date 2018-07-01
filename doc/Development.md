# Install

1. Install [`NodeJs`](https://nodejs.org)

2. Install global `npm` dependencies (**as root/admin**):

        npm install -g gulp livescript@1.4.0


3. Download the project template, install project dependencies:

       git clone --recursive https://github.com/ceremcem/vote-is-well
       cd vote-is-well
       ./scada.js/install-modules.sh

# Run

If you are on Linux, following command will start everything needed for development:

       ./dev.service

In Windows, manually execute every `run-in-tmux` line in a separate command line.
