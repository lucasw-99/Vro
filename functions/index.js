const functions = require('firebase-functions');
const admin = require("firebase-admin");
admin.initializeApp();

const algoliasearch = require('algoliasearch');
const algolia = algoliasearch(functions.config().algolia.appid, functions.config().algolia.adminkey);

exports.updateEvents = functions.database.ref('/events/{eventPostId}').onWrite((eventPost, context) => {
    console.log('eventPost:', eventPost)
    console.log('params:', context)
    const event = eventPost.after.val()["event"]
    const index = algolia.initIndex('events')
    const eventId = event["eventId"]
    if (!event) {
        return index.deleteObject(eventId, (err) => {
            if (err) { 
                console.log('err:', err)
                return false
            }
            console.log('Event Removed from Algolia Index with id:', eventId)
            return true
          })
    }

    event['objectID'] = eventId
    console.log('event:', event)
    return index.saveObject(event, (err, content) => {
        if (err) { 
            console.log('err:', err)
            return false
        }
        console.log('Event Updated in Algolia Index with id:', event.objectID)
        return true
    })    
})