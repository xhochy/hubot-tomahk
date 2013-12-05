hubot-tomahk
==============

Hubot Plugin to translate various music URLs into unified toma.hk so that you are not restricted to the services of your peers

Installation
------------

1. `npm install` in this repo checkout
2. Copy or symlink `tomahk.coffee` into `HUBOT_DIR/src/scripts`
3. Download some [Tomahawk](http://www.tomahawk-player.org/) resolvers to `<axedir>` (e.g. from http://teom.org/axes/nightly/). At the moment of writing, Soundcloud, Deezer-Metadata, Spotify-Metadata, ex.fm and toma.hk are supported.
4. Set `HUBOT_AXE_DIRECTORY=<axedir>` and restart your hubot

Options
-------

* `HUBOT_AXE_DIRECTORY`: Directory with `*.axe` resolver packages
* `HUBOT_TOMAHK_ANY`: Set to `false` to only react on `np:` prefixed messages
