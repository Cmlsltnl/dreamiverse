$.Model 'Dreamcatcher.Models.ImageBank',{

  update: ( imageId, data, success, error ) ->
    $.ajax {
      url: "/images/#{imageId}.json"
      type: 'put'
      contentType: 'application/json'
      data: JSON.stringify(data)
      dataType: 'json'
      complete: success
      error: error
    }
  
  findImagesById: ( imageIds, data, success, error ) ->
    $.ajax {
      url: "/images.json?ids=#{imageIds}"
      type: 'get'
      dataType: 'json'
      data: data
      success: @callback success
      error: error
    }
    
  getImage: (imageId, data, success, error) ->
    $.ajax {
      url: "/images/#{imageId}.json"
      type: 'get'
      dataType: 'json'
      data: data
      success: @callback success
      error: error
    }
    
  disable: (imageId, data, success, error) ->
    $.ajax {
      url: "/images/#{imageId}/disable.json"
      type: 'post'
      contentType: 'application/json'
      dataType: 'json'
      data: data
      complete: @callback success
      error: error
    }
  
},
{}