describe "Topics", ->
  describe "when replies_per_page is 50", ->

    rememberRepliesPerPage = Topics.replies_per_page

    beforeEach -> Topics.replies_per_page = 50
    afterEach -> Topics.replies_per_page = rememberRepliesPerPage

    describe ".pageOfFloor", ->

      describe "at floor 1", ->
        beforeEach -> @page = Topics.pageOfFloor(1)
        it "should be in page 1", -> expect(@page).toEqual(1)

      describe "at floor 50", ->
        beforeEach -> @page = Topics.pageOfFloor(50)
        it "should be in page 1", -> expect(@page).toEqual(1)

      describe "at floor 51", ->
        beforeEach -> @page = Topics.pageOfFloor(50)
        it "should be in page 2", -> expect(@page).toEqual(1)
