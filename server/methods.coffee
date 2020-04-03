Meteor.methods
#     stringify_tags: ->
#         docs = Docs.find({
#             tags: $exists: true
#             tags_string: $exists: false
#         },{limit:1000})
#         for doc in docs.fetch()
#             # doc = Docs.findOne id
#             console.log 'about to stringify', doc
#             tags_string = doc.tags.toString()
#             console.log 'tags_string', tags_string
#             Docs.update doc._id,
#                 $set: tags_string:tags_string
#             # console.log 'result doc', Docs.findOne doc._id
# #

    # calc_leaders: (selected_tags)->
    #     # console.log selected_tags
    #     match = {}
    #     match.model = 'reddit'
    #
    #     if selected_tags.length > 0 then match.tags = $all: selected_tags
    #     # match.tags = $all: selected_tags
    #     # console.log 'match for tags', match
    #     tag_cloud = Docs.aggregate [
    #         { $match: match }
    #         { $project: "tags": 1 }
    #         { $unwind: "$tags" }
    #         { $group: _id: "$tags", count: $sum: 1 }
    #         { $match: _id: $nin: selected_tags }
    #         # { $match: _id: {$regex:"#{current_query}", $options: 'i'} }
    #         { $sort: count: -1, _id: 1 }
    #         { $limit: 10 }
    #         { $project: _id: 0, name: '$_id', count: 1 }
    #     ], {
    #         allowDiskUse: true
    #     }
    #     res = []
    #     # tag_cloud.toArray()
    #     res = tag_cloud.toArray()
    #     # tag_cloud.forEach (tag, i)=>
    #     #     console.log tag
    #     #     res.push tag
    #     res


    order_meal: (meal_id)->
        meal = Docs.findOne meal_id
        Docs.insert
            model:'order'
            meal_id: meal._id
            order_price: meal.price_per_serving
            buyer_id: Meteor.userId()
        Meteor.users.update Meteor.userId(),
            $inc:credit:-meal.price_per_serving
        Meteor.users.update meal._author_id,
            $inc:credit:meal.price_per_serving
        Meteor.call 'calc_meal_data', meal_id, ->

    calc_meal_data: (meal_id)->
        meal = Docs.findOne meal_id
        console.log meal
        order_count =
            Docs.find(
                model:'order'
                meal_id:meal_id
            ).count()
        console.log 'order count', order_count
        servings_left = meal.servings_amount-order_count
        console.log 'servings left', servings_left

        meal_dish =
            Docs.findOne meal.dish_id
        console.log 'meal_dish', meal_dish
        if meal_dish.ingredient_ids
            meal_ingredients =
                Docs.find(
                    model:'ingredient'
                    _id: $in:meal_dish.ingredient_ids
                ).fetch()

            ingredient_titles = []
            for ingredient in meal_ingredients
                console.log ingredient.title
                ingredient_titles.push ingredient.title
            Docs.update meal_id,
                $set:
                    ingredient_titles:ingredient_titles

        Docs.update meal_id,
            $set:
                order_count:order_count
                servings_left:servings_left

    calc_doc_count: ->
        if Meteor.user()
            doc_count = Docs.find(author_id:Meteor.userId()).count()
            term_count = Terms.find(author_id:Meteor.userId()).count()
            console.log 'doc_count', doc_count
            console.log 'term_count', term_count
            Meteor.users.update Meteor.userId(),
                $set:
                    doc_count: doc_count
                    term_count:term_count

    log_doc_terms: (doc_id)->
        doc = Docs.findOne doc_id
        if doc.tags
            for tag in doc.tags
                Meteor.call 'log_term', tag, ->


    log_term: (term)->
        # console.log 'logging term', term
        found_term =
            Terms.findOne
                title:term
        unless found_term
            Terms.insert
                title:term
            # if Meteor.user()
            #     Meteor.users.update({_id:Meteor.userId()},{$inc: karma: 1}, -> )
            # console.log 'added term', term
        else
            Terms.update({_id:found_term._id},{$inc: count: 1}, -> )
            console.log 'found term', term


    lookup: =>
        selection = @words[4000..4500]
        for word in selection
            console.log 'searching ', word
            # Meteor.setTimeout ->
            Meteor.call 'search_reddit', ([word])
            # , 5000

    rename_key:(old_key,new_key,parent)->
        Docs.update parent._id,
            $pull:_keys:old_key
        Docs.update parent._id,
            $addToSet:_keys:new_key
        Docs.update parent._id,
            $rename:
                "#{old_key}": new_key
                "_#{old_key}": "_#{new_key}"

    remove_tag: (tag)->
        # console.log 'tag', tag
        results =
            Docs.find {
                tags: $in: [tag]
            }
        # console.log 'pulling tags', results.count()
        # Docs.remove(
        #     tags: $in: [tag]
        # )
        for doc in results.fetch()
            res = Docs.update doc._id,
                $pull: tags: tag
            console.log res
