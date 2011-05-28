$.Controller 'Dreamcatcher.Controllers.Application',
  
  userModel: Dreamcatcher.Models.User

  init: ->
    @metaMenu = new Dreamcatcher.Controllers.MetaMenu $('.rightPanel') if $('.rightPanel').exists()
    @comment = new Dreamcatcher.Controllers.Comments $('#entryField') if $('#entryField').exists()
    @entries = new Dreamcatcher.Controllers.Entries $('#entryField') if $("#entryField").exists()
    
    #@entries = new Dreamcatcher.Controllers.Entries $("#newEntry") if $("#newEntry").exists()
    #@books = new Dreamcatcher.Controllers.Books $("#entryField") if $("#entryField").exists()
    
    @initSelectMenu()
    @initTooltips()

  initTooltips: ->
    $('.tooltip').tooltip {
      track: true
      delay: 0
      showURL: false
      showBody: ' - '
      fade: 250
    }
    $('.tooltip-left').tooltip {
      track: true
      delay: 0
      showURL: false
      showBody: ' - '
      positionLeft: true
      fade: 250
      top: 20
    }
  
  initSelectMenu: ->
    $('.select-menu').selectmenu(
      style: 'dropdown'
      menuWidth: "200px"
      positionOptions:
        offset: "0px -37px"
    )

  # TODO: Possibly refactor into jQuery syntax, and remove all other versions.
  fitToContent: (id, maxHeight) ->
    text = if id and id.style then id else document.getElementById(id)
    return 0 if not text
    adjustedHeight = text.clientHeight
    if not maxHeight or maxHeight > adjustedHeight
      adjustedHeight = Math.max(text.scrollHeight, adjustedHeight)
      adjustedHeight = Math.min(maxHeight, adjustedHeight) if maxHeight
      text.style.height = adjustedHeight + 80 + 'px' if adjustedHeight > text.clientHeight    

  '#bodyClick click': ->
    @metaMenu.hideAllPanels() if @metaMenu? #use subscribe/publish?
    
  #TODO: eventually remove '.comment_body' to apply to all 'textarea's
  '.comment_body keyup': (el) ->
    @fitToContent el.attr("id"),0
    
  '.button.appearance click': (el) ->
    @metaMenu.selectPanel 'appearance'
    
  '#entry-appearance click': (el) ->
    @metaMenu.selectPanel 'appearance'
    
  'label.ui-selectmenu-default mouseover': (el) ->
    el.parent().addClass 'default-hover'

  'label.ui-selectmenu-default mouseout': (el) ->
    el.parent().removeClass 'default-hover'

  '.ui-selectmenu-default input click': (el) ->
    $('li',$(el).closest('ul')).removeClass 'default'
    $(el).closest('li').addClass 'default'
    value = $('a:first',el.closest('li')).data 'value'
    type = el.closest('ul').attr('id').replace('-menu','')
    switch type.replace('-list','')
      when 'entryType'
        @userModel.update {'user[default_entry_type]': value}
      when 'sharing'
        @userModel.update {'user[default_sharing_level]': value}

$(document).ready ->
  @dreamcatcher = new Dreamcatcher.Controllers.Application $('#body')