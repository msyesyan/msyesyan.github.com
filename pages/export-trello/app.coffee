window.ExportTrelloApp = angular.module('ExportTrelloApp', ['ngRoute', 'ngCookies', 'ui.bootstrap'])

ExportTrelloApp

.config ['$interpolateProvider', ($interpolateProvider)->
  $interpolateProvider.startSymbol('{(').endSymbol(')}')
]

.config(['$routeProvider', '$locationProvider',
  ($routeProvider, $locationProvider) ->
    $routeProvider
      .when '/login',
        templateUrl: 'partials/login.html'
        controller: 'MainController'
      .when '/boards',
        templateUrl: 'partials/boards.html'
        controller: 'BoardsController'
      .when '/lists',
        templateUrl: 'partials/lists.html'
        controller: 'ListsController'
      .otherwise
        redirectTo: '/login'
])

.factory('TrelloService', ['$http', '$cookieStore', ($http, $cookieStore) ->
  class TrelloService
    APIENDPOINT = "https://api.trello.com/1/"

    @authorized = ->
      !!@token()

    @token = ->
      $cookieStore.get("trelloToken")

    @setToken = ->
      $cookieStore.put("trelloToken", Trello.token())

    @user = ->
      $cookieStore.get("trelloUser")

    @setUser = (username) ->
      $cookieStore.put('trelloUser', username)

    @boards = ->
      $http.get APIENDPOINT + "members/#{@user()}/boards?key=9115435cc98b67a65c3a6dcff606cb09&token=#{@token()}&filter=open"

    @lists = (boardId) ->
      $http.get APIENDPOINT + "boards/#{boardId}/lists?key=9115435cc98b67a65c3a6dcff606cb09&token=#{@token()}"

    @cards = (listId) ->
      $http.get APIENDPOINT + "lists/#{listId}/cards?key=9115435cc98b67a65c3a6dcff606cb09&token=#{@token()}&filter=open"
])

.controller('MainController', ['$scope', '$http', '$location', '$rootScope', 'TrelloService', ($scope, $http, $location, $rootScope, TrelloService) ->
  $scope.username = null
  $scope.TrelloService = TrelloService

  $scope.login = (okUrl) ->
    TrelloService.setUser($scope.username)

    Trello.authorize
      type: "popup"
      success: ->
        TrelloService.setToken()
        $location.path okUrl || "/boards"

  $scope.logout = (okUrl) ->
    Trello.deauthorize()
    TrelloService.setToken()
    TrelloService.setUser(null)
    $location.path okUrl || 'login'

  $scope.authorized = ->
    TrelloService.authorized()

  $location.path '/boards' if $scope.authorized()
])

.controller('BoardsController', ['$scope', '$location', '$http', '$rootScope', 'TrelloService', ($scope, $location, $http, $rootScope, TrelloService) ->
  $scope.boards = []

  $scope.index = ->
    TrelloService.boards().then (response) ->
      $scope.boards = response.data

  $scope.lists = (id) ->
    $location.path('lists').search(boardId: id)

  $scope.index()
])

.controller('ListsController', ['$scope', '$location', '$http', '$rootScope', 'TrelloService', ($scope, $location, $http, $rootScope, TrelloService) ->
  $scope.board = null
  $scope.selectedListId = null
  $scope.cards = null

  $scope.drawPaper = ->
    projects = {}

    for card in $scope.cards
      break if !card.name.match(/\{(.*)}/)

      projectKeyTitle = card.name.match(/\{(.*)}/)[1]
      projects[projectKeyTitle] = []  unless projects[projectKeyTitle]
      projects[projectKeyTitle].push card

    $("#paper").empty()

    for project of projects
      $("<h2 />",
        text: project
      ).appendTo "#paper"

      for card in projects[project]
        # content = $.trim(card.name.replace(/\{.*\}|\(.*\)|\[.*\]/g, ""))
        content = card.name

        $("<div/>",
          text: content
        ).appendTo "#paper"

  $scope.index = ->
    TrelloService.lists($location.search().boardId).then (response) ->
      $scope.lists = response.data
      $scope.selectedListId ||= $scope.lists[0].id
      $scope.show($scope.selectedListId)

  $scope.show = (id) ->
    $scope.selectedListId = id
    TrelloService.cards(id).then (response) ->
      $scope.cards = response.data
      $scope.drawPaper()

  $scope.index()
])
