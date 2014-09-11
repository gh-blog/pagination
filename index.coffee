through2 = require 'through2'
File = require 'vinyl'
sort = require 'lodash.sortby'

module.exports = (options = { postsPerPage: 5 }) ->
    { postsPerPage } = options

    dateComparator = (post) ->
        try
            return post.created.date.getTime()
        catch err
            return 0

    posts = []

    processFile = (file, enc, done) ->
        if file.isPost
            posts.push file
            done null, null

        else done null, file

    through2.obj processFile, (done) ->
        pages = []

        # Sort by creation date
        posts =
            sort(posts, dateComparator)
            .map (post, index, collection) ->
                # Add previous and next post
                if index > 0
                    post.prev = collection[index - 1]
                if index < collection.length - 1
                    post.next = collection[index + 1]
                post

        # _num_total = Math.ceil posts.length / postsPerPage
        # console.log "Total pages: #{_num_total}" @TODO: log info

        _page_num = 0
        for post, i in posts by postsPerPage
            pages[_page_num] = []

            pages[_page_num] =
                posts[i...i + postsPerPage]
                .map (post) =>
                    post.page = _page_num + 1
                    @push post
                    post

            _page_num += 1

        for page, page_index in pages
            file = new File {
                path: "../pages/#{page_index + 1}.html"
            }

            file.data = page
            file.index = page_index
            file.isIndexPage = yes

            @push file

        done()