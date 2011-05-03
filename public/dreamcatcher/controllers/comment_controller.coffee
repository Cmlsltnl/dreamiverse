$.Controller 'Dreamcatcher.Controllers.Comment',

  #TODO: [Architectual] Could abstract into Abstract class Comment, with StreamComment, and EntryComment inheriting. 

  init: ->
    @currentUserId = parseInt $("#userInfo").data 'id'
    @currentUserImageId = parseInt $("#userInfo").data 'imageid'
    @entryView = $("#showEntry").length > 0
    
    if @entryView #single entry view
      @entryId = $('#showEntry').data 'id'
      @loadComments $('#showEntry'),@entryId
    else #stream view
      $(".thumb-1d").each (index,element) =>
        entry = $(element)
        newCount = @getNewCommentCount(entry)
        entryId = entry.data('id') 
        @loadComments entry,entryId if newCount > 0

  #Helper Methods
  getEntry: (id) ->
    return $("#showEntry") if @entryView 
    return $(".thumb-1d[data-id='#{id}']")
    
  getEntryId: (el) ->
    return @entryId if @entryView
    return el.data('id') if el.hasClass("thumb-1d")
    return $(el.closest(".thumb-1d")).data('id')
    
  getEntryFromElement: (el) ->
    return $("#showEntry") if @entryView
    return el.closest(".thumb-1d")
    
  getNewCommentCount: (entry) ->
    newCount = $(".newComments",entry).val()
    newCount = 0 if not newCount?
    return parseInt newCount

  getTotalCommentCount: (entry) ->
    commentsLoaded = $(".prevCommentWrap",entry).length
    return commentsLoaded if commentsLoaded > 0
      
    commentCountText = $(".comment .count span",entry).text().trim()
    return parseInt commentCountText if commentCountText.length > 0
    return 0

    
  updateCommentCount: (entry) ->
    totalCount = @getTotalCommentCount entry
    
    $(".showAll span,.count span",entry).text totalCount
    $(".comment",entry).removeClass "new"
    
    if totalCount > 0
      $(".comment .count span",entry).text(totalCount).removeClass("empty")
    else
      $(".comment .count span",entry).text("").addClass("empty")
      

  loadComments: (entry, entryId) -> 
    $(".commentsTarget",entry).addClass("commentsPanel wrapper").html(
      @view 'init',{
        imageId: @currentUserImageId
        entryId: entryId
      })
    $(".comments",entry).addClass("spinner") if @getTotalCommentCount(entry) > 0
    Dreamcatcher.Models.Comment.findEntryComments entryId,{},@callback('populateComments',entry,entryId)
    
  populateComments: (entry, entryId, comments) ->
    totalCount = comments.length
    if @entryView
      numberToShow = totalCount
      $(".commentsHeader span",entry).text totalCount
    else
      newCount = @getNewCommentCount entry
      numberToShow = if newCount > 0 then newCount else 2   #show all 'new' items, or just latest 2
      numberToShow = Math.min totalCount,numberToShow       #make sure numberToShow does not exceed total
      $(entry).addClass "expanded"
      if numberToShow < totalCount
        $(".showAll span",entry).text totalCount
        $(".showAll",entry).show()
    $(".comments",entry).html(
      @view 'list',{
        comments: comments
        userId: @currentUserId
        entryUserId: entry.data("userid")
        numberToShow: numberToShow
      }
    ).removeClass("spinner")

  created: (data) ->
    comment = data.comment
    comment.username = $(".rightPanel .user span").text().trim()
    entryId = comment.entry_id
    entry = @getEntry entryId
    $(".comments",entry).append(
      @view 'show',{
        comment: comment
        showDelete: true
        hidden: false
      })
    
    $(".prevCommentWrap:last",entry).show()
    
    $(".comment_body",entry).val ''
    $(".comment_body,.save",entry).removeAttr("disabled",false).removeClass("disabled")
    
    @updateCommentCount entry

  '.comment click': (el) ->
    entry = @getEntryFromElement el
    entryId = @getEntryId entry
    
    if entry.hasClass("expanded")                 #currently expanded -> collapse
      $(".commentsTarget",entry).hide()
      entry.removeClass("expanded")
    else if $(".commentsPanel",entry).length > 0  #already been expanded -> re-expand
      $(".commentsTarget",entry).show()
      entry.addClass("expanded")
    else                                          #never been expanded -> populate    
      @loadComments entry,entryId
  
  '.showAll click': (el) ->
    entry = @getEntryFromElement el
    $(".prevCommentWrap",entry).show()
    el.hide()
    
  '.deleteComment click': (el) ->
    return if not confirm('confirm you want to delete this comment:')    
    entry = @getEntryFromElement el
    entryId = el.data 'entryid'
    commentId = el.data 'id'
    Dreamcatcher.Models.Comment.delete entryId,commentId
    el.closest('.prevCommentWrap').remove()
    @updateCommentCount entry
    
  '.comment_body focus': (el) ->
    if el.height() < 40
      el.animate({height: '40px'}, 'fast')
      $(".save", el.parent()).fadeIn 200,->
        $(this).removeClass("hidden")
  
  '.save click': (el) ->
    return if $(".comment_body",el.parent()).val().trim().length is 0
    $(".comment_body,.save",el.parent()).attr("disabled",true).addClass("disabled")
    entry = @getEntryFromElement el
    
    comment = {
      user_id: @currentUserId
      image_id: @currentUserImageId
      body: $(".comment_body",el.parent()).val()
    }
    entryId = @getEntryId el
    Dreamcatcher.Models.Comment.create entryId,comment,@callback('created')