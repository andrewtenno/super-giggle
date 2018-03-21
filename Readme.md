Architecture
---
Went with a MVVM style architecture that is probably a little unnecessary / over the top for the scope of this problem but should allow for easy scaling if I were to continue to develop this app.

I decided to go with an Updater object (which could very easily be used to broadcast changes to other parts of the app if they were interested in updates to the model) which is responsible for talking to the model fetcher and the view model generator. This object takes the dependencies and puts them into a easy-to-use API that should do nicely for separating concerns / responsibilities in the app.

View Models are generated on a background thread to increase the performance and reduce the number of operations that are going to be made on the main thread, which can greatly affect smooth scrolling. Although it probably doesn't have too much benefit in this app (as we aren't doing any crazy text parsing / formatting into attributed strings) if we did want to add that in we would reduce the amount of time spent creating the cell in the table view data source. All of the properly formatted information would be in the view model ready for the cell to apply to its UI elements, which takes a lot of the formatting logic out of the Views and puts them into a place that is more easily tested.

Although there are not very many Unit Tests in the app I wrote it in a way (primarily using dependency injection / attempting to separate concerns as much as possible) so that adding test coverage to the view model generation logic and model parsing would be relatively easy since many of the components in that layer are simple and don't have dependencies on things we can't mock.

Other Items
---

I decided to map each of the logos to an emoji string for display instead of trying to hunt down images to add as assets. Although this is fine for a demo app I've heard that Apple isn't too happy when you use emoji in a non-user-generated text situation so I would think about this further before submitting to the app store.

To reduce the number of calls made with the API key (and to increase the speed of the feedback loop) I added a local data fetcher object that returns the contents of Mock.json. This allowed me to test with real data without having to spend any time waiting for calls to return over the network while developing / debugging.

Instead of adding a new page to the navigation controller I used a modally presented view controller to display the summary for a given Data Item. I felt that we didn't have enough data to constitute pushing a new view controller onto the navigation stack and that the smaller size of the one I am using fits the data a little bit better. Let me know if you have any concerns about it.
