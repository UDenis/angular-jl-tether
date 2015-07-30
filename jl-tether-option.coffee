cssClass = 'highlight'

module.exports = {
    restrict: 'A'
    require: ['^jlTether', 'jlTetherOption']
    controller:['$scope','$element','$attrs', '$parse', '$timeout', ($scope, $element, $attrs, $parse, $timeout)->
        @select = () ->
            $element.addClass(cssClass)
            $element.prop('tabindex', -1);
            $element.focus();
        @unSelect = ()->
            $element.removeClass(cssClass)

        @getOption = ()->
            $parse($attrs.jlTetherOption)($scope)

        @onSelect = ()->
            $timeout =>
                $parse($attrs.jlTetherOnSelect || $attrs.ngClick)($scope)
            , 0

    ]
    link: (scope, element, attrs, cntrs) ->
        cntrs[0].addOption(cntrs[1])

        element.on 'click.jlTetherOption', () =>
            cntrs[0].selectOption(cntrs[1])

        scope.$on '$destroy', () =>
            cntrs[0].removeOption(cntrs[1])
            element.off('jlTetherOption')

}