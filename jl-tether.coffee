###
  AngularJS wrapper for HubSpots's Tether
###

Tether = require 'tether'
TetherOption = require './jl-tether-option.coffee'

prefix = 'jlTether'
optionsToEval = ['constraints', 'enabled'] # these tether options aren't mere strings

KEY = {
    ESC: 27,
    TAB: 9,
    SPACE: 32,
    ENTER: 13,
    DOWN: 40,
    UP: 38
};

jlTetherDire = ['$timeout', ($timeout) ->
    restrict: 'A'
    link: (scope, element, attrs, cntrs) ->
        jlTetherController = cntrs
        tetherOptions = {
            classPrefix: 'drop'
        }

        # pluck out relevant keys from the attributes and remove prefix
        for own key, value of attrs
            if key isnt prefix and (key.indexOf prefix) isnt -1
                strippedKey = key.replace prefix, ''
                optionKey = strippedKey[0].toLowerCase() + strippedKey.slice 1

                if optionKey in optionsToEval
                    tetherOptions[optionKey] = scope.$eval value
                else
                    tetherOptions[optionKey] = value

        # extract out 'tetherOptions' attribute and merge to our options object
        if tetherOptions.options?
            evaledOptions = (scope.$eval tetherOptions.options) || {}
            delete tetherOptions.options
            for own key, value of evaledOptions
                tetherOptions[key] = value

        # the default element will be element[0]
        if not tetherOptions.element?
            tetherOptions.element = element[0]


        targetElement = angular.element(tetherOptions.target);
        dropElement = angular.element(tetherOptions.element);
        jlTetherController.targetElement = targetElement

        element.on 'click.' + prefix, ()=>
            jlTetherController.close()

        targetElement.on 'click.' + prefix, ()=>
            jlTetherController.open()

        onKeyDown = (e)=>
            jlTetherController.open()
            switch e.which
                when KEY.ESC then jlTetherController.close()
                when KEY.DOWN
                    jlTetherController.next()
                    e.preventDefault()
                when KEY.UP
                    jlTetherController.prev()
                    e.preventDefault()
                when KEY.ENTER then jlTetherController.onSselectOption()

        targetElement.on 'keydown.' + prefix, onKeyDown

        dropElement.on 'keydown.' + prefix, onKeyDown

        angular.element(document).on 'click.' + prefix, (e)=>
            if (e.target != targetElement[0])
                jlTetherController.close()

        scope.$on '$destroy', ()->
            jlTetherController.close()
            targetElement.off(prefix)
            dropElement.off(prefix)
            angular.element(document).off(prefix)
            tetherHandle?.destroy()


        $timeout () ->
            tetherHandle = new Tether tetherOptions
            tetherHandle.position() # initial reposition

            # hsTether attribute exists, fill it with the Tether object
            if attrs[prefix]?
                scope[attrs[prefix]] = tetherHandle
        , 0



    controller: ['$element', (element)->
        options = [];
        currentIndex = -1;

        @next = ()->
            options[currentIndex]?.unSelect()

            currentIndex++;
            normalizeIndex()

            options[currentIndex]?.select()

        @prev = ()->
            options[currentIndex]?.unSelect()

            currentIndex--;
            normalizeIndex()

            options[currentIndex]?.select()

        @getSelectedOption = () ->
            options[currentIndex]?.getOption()

        @addOption = (o)->
            options.push o

        @removeOption = (o) ->
            index = options.indexOf(o)
            if (index > -1)
                options.splice(index, 1)

        @selectOption = (o) ->
            options[currentIndex]?.unSelect()
            currentIndex = options.indexOf(o)
            options[currentIndex]?.select()
            @onSselectOption()

        @onSselectOption = () ->
            selectedOption = @getSelectedOption()
            if (selectedOption)
                @targetElement.val selectedOption.name || selectedOption.label || selectedOption.id || selectedOption.value || selectedOption.toString()
                options[currentIndex]?.onSelect(selectedOption)
                @close()

        normalizeIndex = ()=>
            if (currentIndex >= options.length)
                currentIndex = 0;

            if (currentIndex < 0)
                currentIndex = options.length - 1

        @close = () ->
            element.removeClass('drop-open')

        @open = () ->
            element.addClass('drop-open')
    ]
]

module.exports = angular.module 'jlTether', []
.directive prefix, jlTetherDire
.directive prefix + 'Option', ()-> TetherOption
