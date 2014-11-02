.factory('Trello', [->
  class Trello
    @version = 1
    @key = "9115435cc98b67a65c3a6dcff606cb09"
    @token ||= null
    deferred = {}
    ready = {}

    @authorized: -> @token?

    @deauthorize: ->
      @token = null

    authorizeURL = (args) ->
      baseArgs =
        response_type: "token"
        key: @key

    waitUntil = (name, fx) ->
      if ready[name]?
        fx(ready[name])
      else
        (deferred[name] ?= []).push(fx)

    localStorage = window.localStorage
    if localStorage?
      storagePrefix = "trello_"
      readStorage = (key) -> localStorage[storagePrefix + key]
      writeStorage = (key, value) ->
        if value == null
          delete localStorage[storagePrefix + key]
        else
          localStorage[storagePrefix + key] = value
    else
      readStorage = writeStorage = ->

    @opts =
      type: "redirect" #popup
      name: "trello"
      persist: true
      interactive: true
      scope:
        read: true
        write: false
        account: false
      expiration: "never"

    @authorize: (userOpts) ->
      opts = $.extend true, @opts, userOpts

      regexToken = /[&#]?token=([0-9a-f]{64})/

      persistToken = ->
        if opts.persist && @token?
          writeStorage("token", @token)

      if opts.persist
        @token ?= readStorage("token")

      @token ?= regexToken.exec(location.hash)?[1]

      if @authorized()
        persistToken()
        location.hash = location.hash.replace(regexToken, "")
        return opts.success?()

      # If we aren't in interactive mode, and we didn't get the token from
      # storage or from the hash, then we error out here
      if !opts.interactive
        return opts.error?()

      scope = (k for k, v of opts.scope when v).join(",")

      switch opts.type
        when "popup"
          do ->
            waitUntil "authorized", (isAuthorized) =>
              if isAuthorized
                persistToken()
                opts.success?()
              else
                opts.error?()

            width = 420
            height = 470
            left = window.screenX + (window.innerWidth - width) / 2
            top = window.screenY + (window.innerHeight - height) / 2

            origin = ///^ [a-z]+ :// [^/]* ///.exec(location)?[0]
            window.open authorizeURL({ return_url: origin, callback_method: "postMessage", scope, expiration: opts.expiration, name: opts.name}), "trello", "width=#{ width },height=#{ height },left=#{ left },top=#{ top }"
        else
          window.location = authorizeURL({ redirect_uri: location.href, callback_method: "fragment", scope, expiration: opts.expiration, name: opts.name})

      return

])