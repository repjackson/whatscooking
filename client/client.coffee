@selected_tags = new ReactiveArray []
@selected_authors = new ReactiveArray []
@selected_timestamp_tags = new ReactiveArray []
@selected_ingredients = new ReactiveArray []


Router.route '/', (->
    @layout 'layout'
    @render 'home'
    ), name:'home'

window.addEventListener('beforeinstallprompt', (e) =>
    # // Prevent the mini-infobar from appearing on mobile
    e.preventDefault()
    # // Stash the event so it can be triggered later.
    deferredPrompt = e
    # // Update UI notify the user they can install the PWA
    showInstallPromotion()
)


Template.body.events
    # 'install_button': (e)->
    #     # // Hide the app provided install promotion
    #     hideMyInstallPromotion();
    #     # // Show the install prompt
    #     deferredPrompt.prompt();
    #     # // Wait for the user to respond to the prompt
    #     deferredPrompt.userChoice.then((choiceResult) =>
    #         if choiceResult.outcome is 'accepted'
    #             console.log('User accepted the install prompt')
    #         else
    #             console.log('User dismissed the install prompt')
    #     )
    'click a': ->
        $('.global_container')
        .transition('fade out', 250)
        .transition('fade in', 250)

    # 'click .result': ->
    #     $('.global_container')
    #     .transition('fade out', 250)
    #     .transition('fade in', 250)

    'click .log_view': ->
        console.log Template.currentData()
        console.log @
        Docs.update @_id,
            $inc: views: 1

# Template.registerHelper 'my_cart_items', () ->
#     found_items =
#         Docs.find
#             model:'cart_item'
#             _author_id: Meteor.userId()
#     console.log 'found items count', found_items.fetch()
#     found_items


# Template.sidebar.onRendered ->
#     @autorun =>
#         if @subscriptionsReady()
#             Meteor.setTimeout ->
#                 $('.context.example .ui.sidebar')
#                     .sidebar({
#                         context: $('.context.example .bottom.segment')
#                         dimPage: false
#                         transition:  'push'
#                     })
#                     .sidebar('attach events', '.context.example .menu .toggle_sidebar.item')
#             , 500
