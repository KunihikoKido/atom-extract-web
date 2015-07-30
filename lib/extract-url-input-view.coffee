{View} = require 'space-pen'
{TextEditorView} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'


module.exports =
  class UrlInputView extends View
    @content: ({placeholderText}={}) ->
      @div =>
        @label "Type url:"
        @subview 'targetUrl', new TextEditorView(mini: true, placeholderText: placeholderText)

    initialize: ({callback, placeholderText, tag, attr}={}) ->
      @callback = callback
      @tag = tag
      @attr = attr
      @disposables = new CompositeDisposable

      targetUrl = localStorage.getItem("extract-web.lastUrl")
      if targetUrl
        @targetUrl.setText(targetUrl)

      @panel ?= atom.workspace.addModalPanel(item: this)
      @panel.show()
      @targetUrl.focus()

      @disposables.add(atom.commands.add(
        'atom-text-editor', 'core:cancel': => @destroy()))
      @disposables.add(atom.commands.add(
        'atom-text-editor', 'core:confirm': => @confirm()))

    confirm: ->
      targetUrl = @targetUrl.getModel().getText()
      localStorage.setItem("extract-web.lastUrl", targetUrl)
      @callback?(targetUrl: targetUrl, tag: @tag, attr: @attr)
      @destroy()

    destroy: ->
      @disposables?.dispose()
      @panel?.destroy()
