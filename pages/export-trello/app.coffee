window.ExportTrelloApp = angular.module('ExportTrelloApp', ['ngRoute', 'ui.bootstrap'])

ExportTrelloApp

.config ['$interpolateProvider', ($interpolateProvider)->
  $interpolateProvider.startSymbol('{(').endSymbol(')}')
]

.config(['$routeProvider', '$locationProvider',
  ($routeProvider, $locationProvider) ->
    $routeProvider
      .when '/dashboard',
        templateUrl: 'partials/dashboard.html'
        controller: 'MainController'
      .otherwise
        redirectTo: '/dashboard'
])

.factory('TrelloService', ['$http', ($http) ->
  class TrelloService
    @organizations = {}

    @getDatas = (organizationName) ->
      return if @organizations[organizationName]?

      $http.get "https://api.trello.com/1/organizations/" + organizationName + "?boards=open&key=9115435cc98b67a65c3a6dcff606cb09&token=" + Trello.token()
      .success (data, status, headers, config) =>
        @organizations[organizationName] = data
])

.controller('MainController', ['$scope', '$http', '$location', '$rootScope', 'TrelloService', ($scope, $http, $location, $rootScope, TrelloService) ->
  $scope.TrelloService = TrelloService
  $scope.organizationName = "bstar"

  $scope.authorized = -> Trello.authorized()

  $scope.getDatas = ->
    TrelloService.getDatas($scope.organizationName)

  $scope.authorize = ->
    Trello.authorize
      type: "popup"
      success: ->
        TrelloService.getDatas($scope.organizationName)

  $scope.deauthorize = ->
    Trello.deauthorize()

])

.controller('BoardsController', ['$scope', '$location', '$http', '$rootScope', 'TrelloService', ($scope, $location, $http, $rootScope, TrelloService) ->
  $scope.TrelloService = TrelloService
])
