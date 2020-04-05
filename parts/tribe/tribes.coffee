Router.route '/tribes/', -> @render 'tribes'


if Meteor.isClient
    Template.tribes.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'tribe'
        Session.setDefault 'view_mode', 'list'
        Session.setDefault 'tribe_sort_key', 'datetime_available'
        Session.setDefault 'tribe_sort_label', 'available'
        Session.setDefault 'tribe_limit', 5
        # @autorun => @subscribe 'model_docs', 'dish'
        @autorun => @subscribe 'tribe_facets',
            selected_tribe_tags.array()
            Session.get('tribe_limit')
            Session.get('tribe_sort_key')
            Session.get('tribe_sort_direction')

        @autorun => @subscribe 'tribe_results',
            selected_tribe_tags.array()
            Session.get('tribe_limit')
            Session.get('tribe_sort_key')
            Session.get('tribe_sort_direction')


    Template.tribe_card.onCreated ->
        @autorun => Meteor.subscribe 'children', 'tribe_update', @data._id
    Template.tribe_card.helpers
        updates: ->
            Docs.find
                model:'tribe_update'
                parent_id: @_id



    Template.tribes.helpers
        tribes: ->
            Docs.find
                model:'tribe'
        latest_comments: ->
            Docs.find {
                model:'comment'
                parent_model:'tribe'
            },
                limit:5
                sort:_timestamp:-1
        tribe_stats_doc: ->
            Docs.findOne
                model:'tribe_stats'

    Template.tribes.events
        'click .add_tribe': ->
            new_id = Docs.insert
                model:'tribe'
            Router.go "/tribe/#{new_id}/edit"

        'click .recalc_tribes': ->
            Meteor.call 'recalc_tribes', ->

    Template.latest_tribe_updates.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'tribe_update'

    Template.latest_tribe_updates.helpers
        latest_updates: ->
            Docs.find {
                model:'tribe_update'
            },
                limit:5
                sort:_timestamp:-1






if Meteor.isServer
    Meteor.publish 'members', (tribe_id)->
        Meteor.users.find
            _id:$in:@member_ids

    Meteor.publish 'tribe_by_slug', (tribe_slug)->
        Docs.find
            model:'tribe'
            slug:tribe_slug
    Meteor.methods
        calc_tribe_stats: (tribe_slug)->
            tribe = Docs.findOne
                model:'tribe'
                slug: tribe_slug

            member_count =
                tribe.member_ids.length

            tribe_members =
                Meteor.users.find
                    _id: $in: tribe.member_ids

            dish_count = 0
            dish_ids = []
            for member in tribe_members.fetch()
                member_dishes =
                    Docs.find(
                        model:'dish'
                        _author_id:member._id
                    ).fetch()
                for dish in member_dishes
                    console.log 'dish', dish.title
                    dish_ids.push dish._id
                    dish_count++
            # dish_count =
            #     Docs.find(
            #         model:'dish'
            #         tribe_id:tribe._id
            #     ).count()
            tribe_count =
                Docs.find(
                    model:'tribe'
                    tribe_id:tribe._id
                ).count()

            order_cursor =
                Docs.find(
                    model:'order'
                    tribe_id:tribe._id
                )
            order_count = order_cursor.count()
            total_credit_exchanged = 0
            for order in order_cursor.fetch()
                if order.order_price
                    total_credit_exchanged += order.order_price
            tribe_tribes =
                Docs.find(
                    model:'tribe'
                    tribe_id:tribe._id
                ).fetch()

            console.log 'total_credit_exchanged', total_credit_exchanged


            Docs.update tribe._id,
                $set:
                    member_count:member_count
                    tribe_count:tribe_count
                    dish_count:dish_count
                    total_credit_exchanged:total_credit_exchanged
                    dish_ids:dish_ids



    Meteor.publish 'tribe_facets', (
        selected_tribe_tags
        selected_authors
        selected_subreddits
        selected_timestamp_tags
        query
        doc_limit
        doc_sort_key
        doc_sort_direction
        )->
        # console.log 'dummy', dummy
        # console.log 'query', query
        console.log 'selected ingredients', selected_tribe_tags

        self = @
        match = {}
        match.model = 'tribe'
        # if view_images
        #     match.is_image = $ne:false
        # if view_videos
        #     match.is_video = $ne:false
        if selected_tribe_tags.length > 0 then match.tags = $all: selected_tribe_tags
        tribe_tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 10 }
            { $project: _id: 0, title: '$_id', count: 1 }
        ], {
            allowDiskUse: true
        }

        tribe_tag_cloud.forEach (tribe_tag, i) =>
            # console.log 'tribe_tag result ', tribe_tag
            self.added 'tribe_tags', Random.id(),
                title: tribe_tag.title
                count: tribe_tag.count
                # category:key
                # index: i


        self.ready()


    Meteor.publish 'tribe_results', (
        selected_tribe_tags
        doc_limit
        doc_sort_key
        doc_sort_direction
        )->
        # console.log selected_tribe_tags
        if doc_limit
            limit = doc_limit
        else
            limit = 10
        if doc_sort_key
            sort_key = doc_sort_key
        if doc_sort_direction
            sort_direction = parseInt(doc_sort_direction)
        self = @
        match = {model:'tribe'}
        if selected_tribe_tags.length > 0
            match.tags = $all: selected_tribe_tags
            sort = 'price_per_serving'
        else
            # match.tags = $nin: ['wikipedia']
            sort = '_timestamp'
            # match.source = $ne:'wikipedia'
        console.log 'tribe match', match
        console.log 'sort key', sort_key
        console.log 'sort direction', sort_direction
        Docs.find match,
            sort:"#{sort_key}":sort_direction
            # sort:_timestamp:-1
            limit: limit
