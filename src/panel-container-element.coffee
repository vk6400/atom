{CompositeDisposable} = require 'event-kit'

class PanelContainerElement extends HTMLElement
  createdCallback: ->
    @subscriptions = new CompositeDisposable

  getModel: -> @model

  setModel: (@model) ->
    @subscriptions.add @model.onDidAddPanel(@panelAdded.bind(this))
    @subscriptions.add @model.onDidRemovePanel(@panelRemoved.bind(this))
    @subscriptions.add @model.onDidDestroy(@destroyed.bind(this))

    @setAttribute('location', @model.getLocation())

  panelAdded: ({panel, index}) ->
    panelElement = panel.getView()
    panelElement.setAttribute('location', @model.getLocation())
    if index >= @childNodes.length
      @appendChild(panelElement)
    else
      referenceItem = @childNodes[index + 1]
      @insertBefore(panelElement, referenceItem)

    if @model.isModal()
      @enforceModalityFor(panel)
      @subscriptions.add panel.onDidChangeVisible (visible) =>
        @enforceModalityFor(panel) if visible

  panelRemoved: ({panel, index}) ->
    @removeChild(@childNodes[index])

  destroyed: ->
    @subscriptions.dispose()
    @parentNode?.removeChild(this)

  enforceModalityFor: (excludedPanel) ->
    for panel in @model.getPanels()
      panel.hide() unless panel is excludedPanel
    return

module.exports = PanelContainerElement = document.registerElement 'atom-panel-container', prototype: PanelContainerElement.prototype
