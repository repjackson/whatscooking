if Meteor.isClient
    Template.tribe_cloud.onCreated ->
        @autorun -> Meteor.subscribe('tags', selected_tribe_tags.array(), Template.currentData().filter, Template.currentData().limit)

    Template.tribe_cloud.helpers
        all_tribe_tags: ->
            doc_count = Docs.find().count()
            if 0 < doc_count < 3 then Tribe_tags.find { count: $lt: doc_count } else Tribe_tags.find()

        tag_cloud_class: ->
            button_class = switch
                when @index <= 10 then 'big'
                when @index <= 20 then 'large'
                when @index <= 30 then ''
                when @index <= 40 then 'small'
                when @index <= 50 then 'tiny'
            return button_class

        # settings: -> {
        #     position: 'bottom'
        #     limit: 10
        #     rules: [
        #         {
        #             collection: Tags
        #             field: 'title'
        #             matchAll: true
        #             template: Template.tag_result
        #         }
        #         ]
        # }


        selected_tribe_tags: ->
            # model = 'event'
            # console.log "selected_#{model}_tribe_tags"
            selected_tribe_tags.array()


    Template.tribe_cloud.events
        'click .select_tribe_tag': -> selected_tribe_tags.push @title
        'click .unselect_tribe_tag': -> selected_tribe_tags.remove @valueOf()
        'click #clear_tribe_tags': -> selected_tribe_tags.clear()

        'keyup #search': (e,t)->
            e.preventDefault()
            val = $('#search').val().toLowerCase().trim()
            switch e.which
                when 13 #enter
                    switch val
                        when 'clear'
                            selected_tribe_tags.clear()
                            $('#search').val ''
                        else
                            unless val.length is 0
                                selected_tribe_tags.push val.toString()
                                $('#search').val ''
                when 8
                    if val.length is 0
                        selected_tribe_tags.pop()

        'autocompleteselect #search': (event, template, doc) ->
            # console.log 'selected ', doc
            selected_tribe_tags.push doc.title
            $('#search').val ''

        'click #add': ->
            Meteor.call 'add', (err,id)->
                FlowRouter.go "/edit/#{id}"
