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
            posts.push { id: file.id, created: file.created?.date }

        done null, file

    through2.obj processFile, (done) ->
        pages = []

        # Sort by creation date
        posts = sort posts, dateComparator

        # _num_total = Math.ceil posts.length / postsPerPage
        # console.log "Total pages: #{_num_total}" @TODO: log info
        
        _page_num = 0
        for post, i in posts by postsPerPage
            pages[_page_num] = []

            pages[_page_num] =
                posts[i...i + postsPerPage]
                .map (post) ->
                    post.page = _page_num
                    post

            _page_num += 1

        for page, i in pages
            console.log(post.created?.getTime() || 0, post.id, i) for post in page

        indexFile = new File {
            path: 'index.json'
            contents: new Buffer JSON.stringify pages
        }

        indexFile.isIndex = yes

        @push indexFile

        done()