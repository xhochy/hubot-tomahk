# Description:
#   Allows Hubot to resolve Music URLs to unified toma.hk links
#
# Commands:
#   hubot np <url> - Translate the music URL to a toma.hk link and displays metadata
#
# Configuration:
#   HUBOT_AXE_DIRECTORY - Directory with .axe files (Tomahawk Resolvers)
queuedURLs = {}
module.exports = (robot) ->
  robot.hear /(np|nowplaying):? (.*)/i, (msg) ->
      url = msg.match[2]
      console.log(url)
      if canParseUrl(msg.match[2])
          queuedURLs[url] = msg
          lookupUrl(url)

async = require 'async'
glob = require 'glob'
http = require 'http'
path = require 'path'
TomahawkJS = require 'tomahawkjs'
tomahk = require 'tomahk'

sendQueuedMsg = (url, message) ->
    if queuedURLs.hasOwnProperty(url)
        queuedURLs[url].send message
        delete queuedURLs[url]

urlResult = (url, result) ->
    switch result.type
        when 'track'
            tomahk.shortTrackUrl result.artist, result.title, (tomahkUrl) ->
                sendQueuedMsg url, result.artist + ' - ' + result.title + ' ' + tomahkUrl
        when 'album'
            tomahkUrl = tomahk.albumUrl result.artist, result.name
            sendQueuedMsg url, result.artist + ' - ' + result.name + ' ' + tomahkUrl
        when 'playlist'
            tomahk.createPlaylist result.title, result.tracks, (tomahkUrl) ->
                sendQueuedMsg url, result.title + ' - ' + tomahkUrl
        when 'artist'
            tomahkUrl = tomahk.artistUrl result.name
            sendQueuedMsg url, result.name + ' ' + tomahkUrl


axes = []
glob path.join(process.env.HUBOT_AXE_DIRECTORY, '*.axe'), (err, files) ->
    async.map files, TomahawkJS.loadAxe, (err, results) ->
        async.map results, ((item, cb) -> item.getInstance cb), (err, results) ->
            results.forEach  ({instance, context}) ->
                instance.init()
                axes.push instance: instance, context: context
                context.on 'url-result', urlResult

# Ask all resolvers that are capable of urllookup if they could parse this url
canParseUrl = (url) ->
    axes.filter((a) -> a.context.hasCapability('urllookup')).map((a) -> a.instance.canParseUrl(url)).reduce(((a,b) -> a || b), false)

lookupUrl = (url) ->
    axes.filter((a) -> a.context.hasCapability('urllookup') && a.instance.canParseUrl(url)).map((a) -> a.instance.lookupUrl(url))
