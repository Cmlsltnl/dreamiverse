class window.TagsController
  constructor: (containerSelector, mode='edit')->
    @$container = $(containerSelector)
    
    switch mode
      when 'edit'
        @tagViewClass = EditingTagView
        @tagInputClass = TagInput
        @$container.find('.tagAdd').click => $.publish 'tags:create', [@tagInput.value()]
      when 'show'
        @tagViewClass = ShowingTagView
        @tagInputClass = ShowingTagInput
        #@$container.find('.tagAdd').click => $.publish 'tags:create', [@tagInput.value()]

    @tagInput = new @tagInputClass(@$container.find('#newTag'))
    @tagViews = new TagViewList(@tagViewClass)

    $.subscribe 'tags:create', (tagName)=> @createTag(tagName)
    
    
  createTag: (tagName)->
    tag = new Tag(tagName)
    tagView = new @tagViewClass(tag)
    tagView.create()

    @tagViews.$container.append( tagView.createElement() )
    
    @tagViews.add(tagView)

class TagInput
  constructor: ($input)->
    @$input = $input

    @$input.keypress (event) =>
      if event.which is 13
        $.publish 'tags:create', [@value()]
        return false

    $.subscribe 'tags:create', => @clear()
  value: -> @$input.val()
  clear: -> @$input.val('')
  
class ShowingTagInput extends TagInput
  constructor: ($input)->
    super($input)
    @buttonMode = 'expand'
    
    $('.tagInput').css('width', '0px')
    $('.tagThisEntry').click => @addExpandSubmitHandler()
    $('.tagHeader').click => @contractInputField()
  
  addExpandSubmitHandler: ->
    switch @buttonMode
      when 'expand'
        @expandInputField()
      when 'submit' then $.publish 'tags:create', [@value()]
  
  expandInputField: ->
    @buttonMode = 'submit'
    $('.tagInput').animate({width: '250px'})
  contractInputField: ->
    @buttonMode = 'expand'
    $('.tagInput').animate({width: '0px'})
    


    
class TagViewList
  constructor: (tagViewClass)->
    @$container = $('#tag-list')
    @tagViews = []
    
    @tagViewClass = tagViewClass
    @addAllCurrentTags()
    
    @$container.delegate 'div', 'click', (event)=>
      @removeTag($(event.currentTarget).data('id'))
    
    $.subscribe 'tags:remove', (id) =>
      @findByTagId(id).startRemoveFromView()
    
    $.subscribe 'tags:removed', (id) =>
      @findByTagId(id).removeFromView()
  
  addAllCurrentTags: ->
    # Fill up @tagViews with tags for each currently displayed tags
    for $currentElement in @$container.find('.tag')
      $element = $($currentElement)
      id = $element.data('id')
      name = $element.find('.tagContent').text()
      tag = new Tag(name, id)
      tagView = new @tagViewClass( tag )
      tagView.linkElement($element)
      @add(tagView)

  findByTagId: (tagId)->
    return tagView for tagView in @tagViews when tagView.tag.id == tagId

  add: (tagView)->
    @tagViews.push(tagView)
    tagView.fadeIn()

  removeTag: (tagId) ->
    tagViewToRemove = @findByTagId(tagId)
    tagViewToRemove.remove()

class TagView
  constructor: (tag)->
    @tag = tag
    
  tagNode: -> @tag
  linkElement: (element)->
    @$element = element
  createElement: ->
    @$element = $('#empty-tag').clone().attr('id', '').show()
    @$element.addClass('tag')
    @$element.addClass('tagWhat')
    @setValue(@tag.name)
    
    return @$element
  setValue: (tagName) ->
    @$element.find('.tagContent').html(tagName)
  setId: (id) ->
    @$element.attr('data-id', id)
  fadeIn: ->
    # TODO: This should pull the current bg color, change to dark, then animate up to the supposed-to color
    currentBackground = @$element.css('backgroundColor');
    @$element.css('backgroundColor', '#777');
    setTimeout (=> @$element.animate {backgroundColor: currentBackground}, 'slow'), 200
  startRemoveFromView: ->
    @$element.css('backgroundColor', '#ff0000')
  removeFromView: ->
    @$element.fadeOut('fast', =>
      @$element.remove()
    )
    

class EditingTagView extends TagView
  inputHtml: '<input type="hidden" value=":tagName" name="what_tags[]" />'
  createElement: ->
    super()
    @createFormElement()

  createFormElement: ->
    hiddenFieldString = @inputHtml.replace(/:tagName/, @tag.name)
    @$element.append(hiddenFieldString)
  remove: ->
    @removeFromView()
    
class ShowingTagView extends TagView
  # ask for ajax stuff
  constructor: (tag) ->
    super(tag)
  create: ->
    $.subscribe 'tags:id', (id) =>
    # problem area
      unless @tag.id?
        @tag.setId(id)
        @setId(id)
    @tag.create()
    
  remove: ->
    @removeFromView()
    @tag.destroy()


# MAKE THIS STORE THE ID OF THE TAG ALSO
# Tag Model
class Tag
  constructor: (name, id = '') ->
    @name = name
    @id = id
    #@attachToEntry()
  setId: (id) ->
    @id = id
  create: ->
    @entry_id = $('#showEntry').data('id')
    $.ajax {
      type: 'POST'
      url: '/tags'
      data:
        entry_id: @entry_id
        what_name: @name
      success: (data, status, xhr) =>
        @id = data.what_id
        $.publish 'tags:id', [@id]
    }
    #$.post "/tags", { entry_id: @entry_id, what_name: @name }, (data) -> alert "Data Loaded: " + data
  destroy: ->
    $.publish 'tags:remove', [@id]
    @entry_id = $('#showEntry').data('id')
    $.ajax {
      type: 'DELETE'
      url: '/tags/what'
      data:
        entry_id: @entry_id
        what_id: @id
      success: (data, status, xhr) =>
        $.publish 'tags:removed', [@id]
    }
    

    