path = require 'path'
fs = require 'fs-plus'
yaml = require 'js-yaml'
{CompositeDisposable} = require 'atom'
{allowUnsafeNewFunction} = require 'loophole'
client = allowUnsafeNewFunction -> require 'cheerio-httpcli'
urljoin = require('url').resolve
ExtractUrlInputView = require './extract-url-input-view'
notifications = require './notifications'
LoadingView = require './loading-view'


module.exports = ExtractWebsite =
  subscriptions: null

  config:
    userAgent:
      title: 'User-Agent'
      type: 'string'
      default: 'chrome'
      enum: ['android', 'chrome', 'googlebot', 'ie', 'ios', 'opera', 'safari']
    urlPattern:
      title: 'Extract URL Pattern'
      type: 'string'
      default: 'https?://.+'
    configPath:
      title: 'Extract Contents Config Path'
      type: 'string'
      default: path.join __dirname, '..', 'default-config.json'
    outputFormat:
      title: 'Extract Contents Output Format'
      type: 'string'
      default: 'json'
      enum: ['json', 'yaml']
    acceptLanguage:
      title: 'Accept-Language'
      type: 'string'
      default: 'en'
    jsonIndent:
      title: 'JSON Indent Size'
      type: 'integer'
      default: 2
    yamlIndent:
      title: 'YAML Indent Size'
      type: 'integer'
      default: 2

  activate: (state) ->
    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add 'atom-workspace', 'extract-web:extract-link-urls': => @extractUrl(params: {tag: "a", attr: "href"})
    @subscriptions.add atom.commands.add 'atom-workspace', 'extract-web:extract-image-urls': => @extractUrl(params: {tag: "img", attr: "src"})
    @subscriptions.add atom.commands.add 'atom-workspace', 'extract-web:extract-contents': => @extractContents()


  deactivate: ->
    @subscriptions.dispose()

  extractUrl: ({targetUrl, params}={}) ->
    params.tag ?= 'a'
    params.attr ?= 'href'

    if not targetUrl
      options =
        callback: @extractUrl
        params: params
        placeholderText: "http://example.org/..."
      return new ExtractUrlInputView(options)

    loadingView = new LoadingView()
    loadingView.updateMessage("Extract URL: Please wait ... #{targetUrl}")
    urlPattern = atom.config.get("extract-web.urlPattern")

    client.headers["Accept-Language"] =
      atom.config.get("extract-web.acceptLanguage")
    client.setBrowser(atom.config.get("extract-web.userAgent"))

    client.fetch(targetUrl).then((result) ->
      urls = []
      result.$(params.tag).each((idx) ->
        url = urljoin(targetUrl, result.$(this).attr(params.attr))

        if url.match(///#{urlPattern}///)
          urls.push(url)
      )
      urls = urls.unique().sort()
      return urls
    ).then((urls) ->
      editor = atom.workspace.getActiveTextEditor()
      return unless editor?

      for url in urls
        editor.insertText("#{url}\r\n")
      notifications.addSuccess("Extracts : #{urls.length}")
    ).catch((error) ->
      notifications.addError(error)
    ).finally( ->
      loadingView.finish(delay: 1000 * 1)
    )

  extractContents: ({targetUrl}={}) ->
    if not targetUrl
      options =
        callback: @extractContents
        placeholderText: "http://example.org/..."
      return new ExtractUrlInputView(options)

    try
      configPath = atom.config.get("extract-web.configPath")
      extractConfig = fs.readFileSync(configPath)
      extractConfig = JSON.parse(extractConfig)
    catch error
      return notifications.addError(error)

    loadingView = new LoadingView()
    loadingView.updateMessage("Extract Contents: Please wait ... #{targetUrl}")

    client.headers["Accept-Language"] =
      atom.config.get("extract-web.acceptLanguage")
    client.setBrowser(atom.config.get("extract-web.userAgent"))

    client.fetch(targetUrl).then((result) ->
      docInfo = result.$.documentInfo()
      content = {url: targetUrl, urls: [targetUrl], encode: docInfo.encoding}

      if targetUrl != docInfo.url
        content.urls.push(docInfo.url)

      extractConfig.target ?= []

      for target in extractConfig.target
        if targetUrl.match(///#{target.pattern.url}///)
          for property, options of target.properties
            if options.text
              if options.isArray
                content[property] = []
                result.$(options.text).each((idx) ->
                  value = result.$(this).text().normalize()
                  if value.length
                    content[property].push(value)
                )
              else
                content[property] = result.$(options.text).text()?.normalize()
            else if options.html
              if options.isArray
                content[property] = []
                result.$(options.html).each((idx) ->
                  value = result.$(this)._html().normalize()
                  if value.length
                    content[property].push(value)
                )
              else
                content[property] = result.$(options.html)._html()?.normalize()
            else if options.attr
              if options.isArray
                content[property] = []
                result.$(options.attr).each((idx) ->
                  value = result.$(this).attr(options.args[0]).normalize()
                  if value.length
                    content[property].push(value)
                )
              else
                content[property] =
                  result.$(options.attr).attr(options.args[0])?.normalize()
          break

      return content
    ).then((content) ->
      editor = atom.workspace.getActiveTextEditor()
      return unless editor?

      outputFormat = atom.config.get("extract-web.outputFormat")

      if outputFormat is "yaml"
        indent = atom.config.get('extract-web.yamlIndent')
        text = yaml.dump(content, indent: indent)
        editor.setGrammar(atom.grammars.selectGrammar('untitled.yaml'))
      else
        indent = atom.config.get('extract-web.jsonIndent')
        text = JSON.stringify(content, null, indent)
        editor.setGrammar(atom.grammars.selectGrammar('untitled.json'))

      editor.insertText(text)
    ).catch((error) ->
      notifications.addError(error)
    ).finally( ->
      loadingView.finish(delay: 1000 * 1)
    )


Array::unique = ->
  output = {}
  output[@[key]] = @[key] for key in [0...@length]
  value for key, value of output


# unless String::trim then String::trim = ->
String::normalize = ->
  value = @replace /\s{2,}|\t|\r?\n/g, " "
  value.replace /^\s+|\s+$/g, ""
