$("#logout").toggle(Trello.authorized())
$("#login").toggle(!Trello.authorized())

settings =
  applicationName: "ExportTrelloToWeekPapers"
  key: "9115435cc98b67a65c3a6dcff606cb09"
  boardId: "KDFzTG2T"
  i18n:
    hh: "健康到家"
    zbh: "闸北医疗"
    ngb: "智慧闵行"
    cam: "智能摄像头"
    zgav: "张江视听"
    hxl: "沪杏图书馆"
    mportal: "NGBLab"
  labels:
    green: "追加"
    yellow: "等待"
    orange: "讨论"
    red: "失败"
    purple: "待定"
    blue: "解决"

boardId = settings.boardId

initList = ->
  $("#list").empty()
  Trello.boards.get boardId, { lists: "open" }, (board) ->
    $("<h2/>").html("Lists of " + board.name).appendTo('#lists')

    for list in board.lists
      $("<div/>",
        class: "list"
        "data-id": list.id
        text: list.name
      ).appendTo "#lists"

    $(".list").click ->
      $("#output").html("loading....")
      $(this).addClass("active").siblings().removeClass("active")
      Trello.lists.get($(this).data("id"), cards: "open", (list) ->
        projects = {}

        for card in list.cards
          projectKeyTitle = card.name.match(/\{(.*)}/)[1]
          projects[projectKeyTitle] = []  unless projects[projectKeyTitle]
          # projects[projectKeyTitle].push $.trim(card.name.replace(/\{.*\}|\(.*\)|\[.*\]/g, ""))
          projects[projectKeyTitle].push card

        $("#output").empty()
        for project of projects
          $("<h2 />",
            text: settings.i18n[project] or project
          ).appendTo "#output"

          for card in projects[project]
            label = "完成"
            label = settings.labels[card.labels[0].color] if card.labels[0]

            content = $.trim(card.name.replace(/\{.*\}|\(.*\)|\[.*\]/g, ""))
            content = "[" + label + "]" + " " + content

            $("<div/>",
              text: content
            ).appendTo "#output"
      )
  , (error) ->
    alert error

$("#login").click ->
  Trello.authorize
    type: "popup",
    name: settings.applicationName
    success: initList

$("#logout").click ->
  Trello.deauthorize()

# Trello.authorize
#   interactive: false,
#   success: initList,
#   error: ->
#     Trello.authorize
#       type: "popup",
#       name: settings.applicationName
#       success: initList