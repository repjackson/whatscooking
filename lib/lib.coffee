@Docs = new Meteor.Collection 'docs'
@Tags = new Meteor.Collection 'tags'

@Tribe_tags = new Meteor.Collection 'tribe_tags'


@Tribes = new Meteor.Collection 'tribes'
@Ingredients = new Meteor.Collection 'ingredients'
@Timestamp_tags = new Meteor.Collection 'timestamp_tags'

Router.configure
    layoutTemplate: 'layout'
    notFoundTemplate: 'not_found'
    loadingTemplate: 'splash'
    trackPageView: false


if Meteor.isClient
    # console.log $
    $.cloudinary.config
        cloud_name:"facet"

if Meteor.isServer
    # console.log Meteor.settings.private.cloudinary_key
    # console.log Meteor.settings.private.cloudinary_secret
    Cloudinary.config
        cloud_name: 'facet'
        api_key: Meteor.settings.private.cloudinary_key
        api_secret: Meteor.settings.private.cloudinary_secret




Docs.before.insert (userId, doc)->
    if Meteor.user()
        doc._author_id = Meteor.userId()
        doc._author_username = Meteor.user().username
    timestamp = Date.now()
    doc._timestamp = timestamp
    doc._timestamp_long = moment(timestamp).format("dddd, MMMM Do YYYY, h:mm:ss a")
    date = moment(timestamp).format('Do')
    weekdaynum = moment(timestamp).isoWeekday()
    weekday = moment().isoWeekday(weekdaynum).format('dddd')

    hour = moment(timestamp).format('h')
    minute = moment(timestamp).format('m')
    ap = moment(timestamp).format('a')
    month = moment(timestamp).format('MMMM')
    year = moment(timestamp).format('YYYY')

    # date_array = [ap, "hour #{hour}", "min #{minute}", weekday, month, date, year]
    date_array = [ap, weekday, month, date, year]
    if _
        date_array = _.map(date_array, (el)-> el.toString().toLowerCase())
        # date_array = _.each(date_array, (el)-> console.log(typeof el))
        # console.log date_array
        doc._timestamp_tags = date_array

    return


Docs.helpers
    _author: -> Meteor.users.findOne @_author_id
    when: -> moment(@_timestamp).fromNow()
    ten_tags: -> if @tags then @tags[..10]
    five_tags: -> if @tags then @tags[..4]
    # three_tags: -> if @tags then @tags[..2]
    is_visible: -> @published in [0,1]
    # is_published: -> @published is 1
    # is_anonymous: -> @published is 0
    # is_private: -> @published is -1
    from_user: ->
        if @from_user_id
            Meteor.users.findOne @from_user_id
    to_user: ->
        if @to_user_id
            Meteor.users.findOne @to_user_id



    order_meal: ->
        Docs.findOne
            model:'meal'
            _id:@meal_id



    # tribe
    tribe_dishes: ->
        # console.log 'tribe dishes'
        if @dish_ids
            Docs.find
                _id:$in:@dish_ids


    order_total_transaction_amount: ->
        @serving_purchase_price+@cook_tip


    order: ->
        Docs.findOne
            model:'order'
            _id:@order_id

    dish_meals: ->
        Docs.find
            model:'meal'
            dish_id:@_id

    ingredient_dishes: ->
        Docs.find
            model:'dish'
            ingredient_ids: $in: [@_id]


    meal_orders: ->
        # if @order_ids
        Docs.find
            meal_id:@_id
            model:'order'
        # else
        #     []

    meal_dish: ->
        if @dish_id
            Docs.findOne
                model:'dish'
                _id:@dish_id

    dish_ingredients: ->
        if @ingredient_ids
            Docs.find
                model:'ingredient'
                _id:$in:@ingredient_ids


    upvoters: ->
        if @upvoter_ids
            upvoters = []
            for upvoter_id in @upvoter_ids
                upvoter = Meteor.users.findOne upvoter_id
                upvoters.push upvoter
            upvoters
    downvoters: ->
        if @downvoter_ids
            downvoters = []
            for downvoter_id in @downvoter_ids
                downvoter = Meteor.users.findOne downvoter_id
                downvoters.push downvoter
            downvoters


Meteor.users.helpers
    name: ->
        if @nickname
            "#{@nickname}"
        else if @first_name and @last_name
            "#{@first_name} #{@last_name}"
        else
            "#{@username}"
    user_orders: (user_id)->
        if user_id
            Docs.find
                model:'order'
                _author_id: user_id
        else
            Docs.find
                model:'order'
                _author_id: Meteor.userId()
    # is_current_user: ->
    #     if @roles
    #         if 'admin' in @roles
    #             if 'user' in @current_roles then true else false
    #         else
    #             if 'user' in @roles then true else false
    user_tribes: ->
        Docs.find
            model:'tribe'
            member_ids:
                $in:[@_id]
    email_address: -> if @emails and @emails[0] then @emails[0].address
    email_verified: -> if @emails and @emails[0] then @emails[0].verified
    five_tags: -> if @tags then @tags[..4]
    three_tags: -> if @tags then @tags[..2]
    last_name_initial: -> if @last_name then @last_name.charAt 0

Meteor.methods
    upvote: (doc)->
        if Meteor.userId()
            if doc.downvoter_ids and Meteor.userId() in doc.downvoter_ids
                Docs.update doc._id,
                    $pull: downvoter_ids:Meteor.userId()
                    $addToSet: upvoter_ids:Meteor.userId()
                    $inc:
                        points:2
                        upvotes:1
                        downvotes:-1
            else if doc.upvoter_ids and Meteor.userId() in doc.upvoter_ids
                Docs.update doc._id,
                    $pull: upvoter_ids:Meteor.userId()
                    $inc:
                        points:-1
                        upvotes:-1
            else
                Docs.update doc._id,
                    $addToSet: upvoter_ids:Meteor.userId()
                    $inc:
                        upvotes:1
                        points:1
            Meteor.users.update doc._author_id,
                $inc:karma:1
        else
            Docs.update doc._id,
                $inc:
                    anon_points:1
                    anon_upvotes:1
            Meteor.users.update doc._author_id,
                $inc:anon_karma:1

    downvote: (doc)->
        if Meteor.userId()
            if doc.upvoter_ids and Meteor.userId() in doc.upvoter_ids
                Docs.update doc._id,
                    $pull: upvoter_ids:Meteor.userId()
                    $addToSet: downvoter_ids:Meteor.userId()
                    $inc:
                        points:-2
                        downvotes:1
                        upvotes:-1
            else if doc.downvoter_ids and Meteor.userId() in doc.downvoter_ids
                Docs.update doc._id,
                    $pull: downvoter_ids:Meteor.userId()
                    $inc:
                        points:1
                        downvotes:-1
            else
                Docs.update doc._id,
                    $addToSet: downvoter_ids:Meteor.userId()
                    $inc:
                        points:-1
                        downvotes:1
            Meteor.users.update doc._author_id,
                $inc:karma:-1
        else
            Docs.update doc._id,
                $inc:
                    anon_points:-1
                    anon_downvotes:1
            Meteor.users.update doc._author_id,
                $inc:anon_karma:-1



    add_facet_filter: (delta_id, key, filter)->
        if key is '_keys'
            new_facet_ob = {
                key:filter
                filters:[]
                res:[]
            }
            Docs.update { _id:delta_id },
                $addToSet: facets: new_facet_ob
        Docs.update { _id:delta_id, "facets.key":key},
            $addToSet: "facets.$.filters": filter

        Meteor.call 'fum', delta_id, (err,res)->


    remove_facet_filter: (delta_id, key, filter)->
        if key is '_keys'
            Docs.update { _id:delta_id },
                $pull:facets: {key:filter}
        Docs.update { _id:delta_id, "facets.key":key},
            $pull: "facets.$.filters": filter
        Meteor.call 'fum', delta_id, (err,res)->
