$.Controller 'Dreamcatcher.Controllers.Settings',

  init: ->
    @setupDefaults()
    @setupAjaxBinding()
  
  setupDefaults: ->
    # Gather the in page defaults
    defaultLandingPage = $('#default-landingPage').data 'id'
    defaultMenuStyle = $('#default-menuStyle').data 'id'
    defaultFontSize = $('#default-fontSize').data 'id'
    
    # Set the pulldown defaults
    $('#default-landingPage-list').val(defaultLandingPage)
    $('#default-menuStyle-list').val(defaultMenuStyle)

    @displayDefaultLandingPage defaultLandingPage
 
 
  showPanel: ->    
    $('#settingsPanel').show()


  updateSettingsModel: (params) ->
    Dreamcatcher.Models.Settings.update params
    
        
  # Default settings display methods
  displayDefaultLandingPage: (defaultLandingPage) ->
    landingIcon = $('#default-landingPage-icon')
    landingIcon.removeClass(className) for className in ['stream','home','today']
    landingIcon.addClass(defaultLandingPage)

  displayDefaultMenuStyle: (defaultMenuStyle) ->
    pageBody = $('#body')
    pageBody.removeClass(className) for className in ['float','inpage']
    pageBody.addClass(defaultMenuStyle)

  displayDefaultFontSize: (defaultFontSize) ->
    pageBody = $('#body')
    pageBody.removeClass(className) for className in ['fontSmall','fontMedium','fontLarge']
    pageBody.addClass(defaultFontSize)
 
    
  # Listener methods
  '#default-landingPage-list change': (element) ->
    defaultLandingPage = element.val()
    @displayDefaultLandingPage defaultLandingPage
    @updateSettingsModel {'user[default_landing_page]': defaultLandingPage} 

  '#default-menuStyle-list change': (element) ->
    defaultMenuStyle = element.val()
    @displayDefaultMenuStyle defaultMenuStyle
    @updateSettingsModel {'user[view_preference][default_menu_style]': defaultMenuStyle} 

  '#default-fontSize .fontSize click': (element) ->
    defaultFontSize = element.attr("id")
    @displayDefaultFontSize defaultFontSize
    @updateSettingsModel {'user[view_preference][default_font_size]': defaultFontSize}

  '.cancel click': ->
    $('.changePasswordForm').hide()
    $('#user_password,#user_password_confirmation').val ''
    
  # Facebook and change password code: TODO: Needs refactoring
  setupAjaxBinding: ->
    $('#fbLink').bind 'ajax:success', (event, xhr, status)->
      $('#fbLink').remove()
      $('.network').append '<a id="fbLink" href="/auth/facebook" class="linkAccount">link account</a>'

    $('form#change_password').bind 'ajax:beforeSend', (xhr, settings)->
      $('.changePassword .target').hide()

    $('form#change_password').bind 'ajax:success', (data, xhr, status)->
      $('p.notice').text xhr.message
      if xhr.errors
        for error, message of xhr.errors
          $('#user_' + error).prev().text message[0]
        $('.changePassword .target').slideDown 250
      else
        $('#change_password .error').text ''
        $('#user_old_password, #user_password, #user_password_confirmation').val ''

    $('form#change_password').bind 'ajax:error', (xhr, status, error)->
      log xhr.errors    