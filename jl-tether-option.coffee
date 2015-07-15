cssClass = 'highlight'

module.exports = {
    restrict: 'A'
    require: ['^jlTether', 'jlTetherOption']
    controller:['$scope','$element','$attrs', '$parse', ($scope, $element, $attrs, $parse)->
        @select = () ->
            $element.addClass(cssClass)
        @unSelect = ()->
            $element.removeClass(cssClass)

        @getOption = ()->
            $parse($attrs.jlTetherOption)($scope)

        @onSelect = ()->
            $parse($attrs.jlTetherOnSelect || $attrs.ngClick)($scope)

    ]
    link: (scope, element, attrs, cntrs) ->
        cntrs[0].addOption(cntrs[1])

        element.on 'click.jlTetherOption', () =>
            cntrs[0].selectOption(cntrs[1])

        scope.$on '$destroy', () =>
            cntrs[0].removeOption(cntrs[1])
            element.on('jlTetherOption')

}