if Meteor.isClient
    Template.tiffen.onCreated ->
        Session.setDefault 'view_incomplete', false
        @autorun => @subscribe 'orders',
            Session.get('view_incomplete')
            


    Template.tiffen.events
        'click .order': ->
            Docs.insert 
                model:'order'
                amount:15
                
        'click .view_incomplete': ->
            Session.set('view_incomplete', !Session.get('view_incomplete'))
            

    Template.tiffen.helpers
        orders: ->
            Docs.find 
                model:'order'
    
        
            
if Meteor.isServer
    Meteor.publish 'orders', (
        viewing_incomplete
        viewing_today
        doc_sort_key
        doc_sort_direction
        )->
            
        match = {}
        # console.log selected_ingredients
        if viewing_incomplete
            match.complete = $ne:true
        # if doc_sort_key
        #     sort_key = doc_sort_key
        # if doc_sort_direction
        #     sort_direction = parseInt(doc_sort_direction)
        self = @
        match = {model:'order'}
        # if selected_ingredients.length > 0
        #     match.ingredient_titles = $all: selected_ingredients
        #     sort = 'price_per_serving'
        # else
        #     # match.tags = $nin: ['wikipedia']
        #     sort = '_timestamp'
            # match.source = $ne:'wikipedia'
        # if view_images
        # match.tags = $all: selected_ingredients
        # if filter then match.model = filter
        # keys = _.keys(prematch)
        # for key in keys
        #     key_array = prematch["#{key}"]
        #     if key_array and key_array.length > 0
        #         match["#{key}"] = $all: key_array
            # console.log 'current facet filter array', current_facet_filter_array
    
        Docs.find match