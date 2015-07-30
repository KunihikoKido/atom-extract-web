{CompositeDisposable} = require 'atom'
{allowUnsafeNewFunction} = require 'loophole'
client = allowUnsafeNewFunction -> require 'cheerio-httpcli'
urljoin = require('url').resolve
ExtractUrlInputView = require './extract-url-input-view'


module.exports = ExtractWebsite =
  subscriptions: null

  config:
    extractUrlPattern:
      type: 'string'
      default: 'https?:\/\/.+'

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up
    # with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'extract-web:extract-link-urls': => @extractUrl(tag: "a", attr: "href")
    @subscriptions.add atom.commands.add 'atom-workspace', 'extract-web:extract-image-urls': => @extractUrl(tag: "img", attr: "src")

  deactivate: ->
    @subscriptions.dispose()

  extractUrl: ({targetUrl, tag, attr}={}) ->

    if not targetUrl
      options =
        callback: @extractUrl
        tag: tag
        attr: attr
        placeholderText: "http://example.org/..."
      return new ExtractUrlInputView(options)

    client.fetch(targetUrl).then((result) ->
      urls = []
      result.$(tag).each((idx) ->
        url = urljoin(targetUrl, result.$(this).attr(attr))
        pattern = atom.config.get("extract-web.extractUrlPattern")
        if url.match(///#{pattern}///)
          urls.push(url)
      )
      urls = urls.unique().sort()
      return urls
    ).then((urls) ->
      editor = atom.workspace.getActiveTextEditor()
      return unless editor?

      for url in urls
        editor.insertText("#{url}\r\n")
    ).catch((error) ->
      console.log(error)
    )

Array::unique = ->
  output = {}
  output[@[key]] = @[key] for key in [0...@length]
  value for key, value of output
