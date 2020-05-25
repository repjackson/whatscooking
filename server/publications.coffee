Meteor.publish 'current_doc ', (doc_id)->
    console.log 'pulling doc'
    Docs.find doc_id


Meteor.publish 'model_docs', (model)->
    # console.log 'pulling doc'
    Docs.find
        model:model

# Meteor.publish 'meals', (model)->
#     # console.log 'pulling doc'
#     Docs.find
#         model:'meal'

Meteor.publish 'user_from_username', (username)->
    # console.log 'pulling doc'
    Meteor.users.find
        username:username


Meteor.publish 'children', (model, parent_id, limit)->
    # console.log model
    # console.log parent_id
    limit = if limit then limit else 10
    Docs.find {
        model:model
        parent_id:parent_id
    }, limit:limit


Meteor.publish 'meal_facets', (
    selected_ingredients
    selected_timestamp_tags
    query
    doc_sort_key
    doc_sort_direction
    )->
    # console.log 'dummy', dummy
    # console.log 'query', query
    console.log 'selected ingredients', selected_ingredients

    self = @
    match = {}
    match.model = 'meal'
    # if view_images
    #     match.is_image = $ne:false
    # if view_videos
    #     match.is_video = $ne:false
    if selected_ingredients.length > 0 then match.ingredient_titles = $all: selected_ingredients
        # match.$regex:"#{current_query}", $options: 'i'}
    # if query and query.length > 1
    # #     console.log 'searching query', query
    # #     # match.tags = {$regex:"#{query}", $options: 'i'}
    # #     # match.tags_string = {$regex:"#{query}", $options: 'i'}
    # #
    #     Terms.find {
    #         title: {$regex:"#{query}", $options: 'i'}
    #     },
    #         sort:
    #             count: -1
    #         limit: 20
        # tag_cloud = Docs.aggregate [
        #     { $match: match }
        #     { $project: "tags": 1 }
        #     { $unwind: "$tags" }
        #     { $group: _id: "$tags", count: $sum: 1 }
        #     { $match: _id: $nin: selected_ingredients }
        #     { $match: _id: {$regex:"#{query}", $options: 'i'} }
        #     { $sort: count: -1, _id: 1 }
        #     { $limit: 42 }
        #     { $project: _id: 0, name: '$_id', count: 1 }
        #     ]

    # else
    # unless query and query.length > 2
    # if selected_ingredients.length > 0 then match.tags = $all: selected_ingredients
    # # match.tags = $all: selected_ingredients
    # # console.log 'match for tags', match
    # tag_cloud = Docs.aggregate [
    #     { $match: match }
    #     { $project: "tags": 1 }
    #     { $unwind: "$tags" }
    #     { $group: _id: "$tags", count: $sum: 1 }
    #     { $match: _id: $nin: selected_ingredients }
    #     # { $match: _id: {$regex:"#{current_query}", $options: 'i'} }
    #     { $sort: count: -1, _id: 1 }
    #     { $limit: 20 }
    #     { $project: _id: 0, name: '$_id', count: 1 }
    # ], {
    #     allowDiskUse: true
    # }
    #
    # tag_cloud.forEach (tag, i) =>
    #     # console.log 'queried tag ', tag
    #     # console.log 'key', key
    #     self.added 'tags', Random.id(),
    #         title: tag.name
    #         count: tag.count
    #         # category:key
    #         # index: i


    ingredient_cloud = Docs.aggregate [
        { $match: match }
        { $project: "ingredient_titles": 1 }
        { $unwind: "$ingredient_titles" }
        { $group: _id: "$ingredient_titles", count: $sum: 1 }
        { $sort: count: -1, _id: 1 }
        { $limit: 10 }
        { $project: _id: 0, title: '$_id', count: 1 }
    ], {
        allowDiskUse: true
    }

    ingredient_cloud.forEach (ingredient, i) =>
        # console.log 'ingredient result ', ingredient
        self.added 'ingredients', Random.id(),
            title: ingredient.title
            count: ingredient.count
            # category:key
            # index: i


    self.ready()


Meteor.publish 'doc', (doc_id)->
    Docs.find doc_id

Meteor.publish 'meal_results', (
    selected_ingredients
    doc_limit
    doc_sort_key
    doc_sort_direction
    )->
    # console.log selected_ingredients
    if doc_limit
        limit = doc_limit
    else
        limit = 10
    if doc_sort_key
        sort_key = doc_sort_key
    if doc_sort_direction
        sort_direction = parseInt(doc_sort_direction)
    self = @
    match = {model:'meal'}
    if selected_ingredients.length > 0
        match.ingredient_titles = $all: selected_ingredients
        sort = 'price_per_serving'
    else
        # match.tags = $nin: ['wikipedia']
        sort = '_timestamp'
        # match.source = $ne:'wikipedia'
    # if view_images
    #     match.is_image = $ne:false
    # if view_videos
    #     match.is_video = $ne:false

    # match.tags = $all: selected_ingredients
    # if filter then match.model = filter
    # keys = _.keys(prematch)
    # for key in keys
    #     key_array = prematch["#{key}"]
    #     if key_array and key_array.length > 0
    #         match["#{key}"] = $all: key_array
        # console.log 'current facet filter array', current_facet_filter_array

    console.log 'meal match', match
    console.log 'sort key', sort_key
    console.log 'sort direction', sort_direction
    Docs.find match,
        sort:"#{sort_key}":sort_direction
        # sort:_timestamp:-1
        limit: limit
