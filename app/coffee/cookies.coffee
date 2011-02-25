setCookie = (name, value, days) ->
  if days
    date = new Date()
    date.setTime(date.getTime() + (days*24*60*60*1000))
    expires = "; expires=" + date.toGMTString()
  else
    expires = ""
  document.cookie = name + '=' + value + expires + '; path=/'

getCookie = (name) ->
  nameEQ = name + '='
  ca = document.cookie.split(';')
  for cookie in ca
    cookie.substring(1,c.length) while cookie.charAt(0) is ' '
    if cookie.indexOf(nameEQ) is 0
      return cookie.substring(nameEQ.length, cookie.length)
  
  return null

deleteCookie = (name) ->
  setCookie(name, '', -1)