HTMLFixture =
  replies: (count) ->
    html = '<div id="replies">'
    html += ("<span class=\"reply\" id=\"reply#{i}\"></span>" for i in [1..count]).join('')
    html += '</div>'
    html

describe "Topics", ->
  describe "when replies_per_page is 50", ->

    rememberRepliesPerPage = Topics.replies_per_page

    beforeEach -> Topics.replies_per_page = 50
    afterEach -> Topics.replies_per_page = rememberRepliesPerPage

    describe ".pageOfFloor", ->

      describe "at floor 1", ->
        beforeEach -> @page = Topics.pageOfFloor(1)
        it "is in in page 1", -> expect(@page).toEqual(1)

      describe "at floor 50", ->
        beforeEach -> @page = Topics.pageOfFloor(50)
        it "is in in page 1", -> expect(@page).toEqual(1)

      describe "at floor 51", ->
        beforeEach -> @page = Topics.pageOfFloor(50)
        it "is in in page 2", -> expect(@page).toEqual(1)

    describe ".highlightReply", ->

      describe "when there are 3 replies", ->
        beforeEach -> @htmlContainer.append HTMLFixture.replies(3)
        describe "when no replies is highlighted", ->

          describe "highlights #reply2", ->

            beforeEach ->
              @reply2 = @htmlContainer.find('#reply2')
              Topics.highlightReply(@reply2)

            it "adds class light to #reply2", ->
              expect(@reply2.hasClass('light')).toBeTruthy()

            it "adds class light to only one reply", ->
              expect(@htmlContainer.find('.reply.light').length).toEqual(1)


        describe "when #reply1 is hightlighed", ->
          beforeEach ->
            @reply1 = @htmlContainer.find('#reply1')
            @reply1.addClass 'light'

          describe "highlights #reply2", ->

            beforeEach ->
              @reply2 = @htmlContainer.find('#reply2')
              Topics.highlightReply(@reply2)

            it "removes class light from #reply1", ->
              expect(@reply1.hasClass('light')).toBeFalsy()

            it "adds class light to #reply2", ->
              expect(@reply2.hasClass('light')).toBeTruthy()

            it "adds class light to only one reply", ->
              expect(@htmlContainer.find('.reply.light').length).toEqual(1)

    describe '.gotoFloor', ->
      describe 'when there are 3 replies', ->
        beforeEach -> @htmlContainer.append HTMLFixture.replies(3)

        describe 'goto floor 3', ->

          beforeEach -> Topics.gotoFloor(3)

          it 'does not redirect', ->
            expect(App.lastGotoUrl).toBeNull()

          it 'highlight reply3', ->
            expect(@htmlContainer.find('#reply3').hasClass('light')).toBeTruthy()


      describe 'when there are 3 replies', ->
        beforeEach -> @htmlContainer.append HTMLFixture.replies(3)

        describe 'goto floor 51', ->

          beforeEach -> Topics.gotoFloor(51)

          it 'redirects to URL with query page=2', ->
            expect(App.lastGotoUrl).toMatch(/\?page=2/)

          it 'redirects to URL with hash reply51', ->
            expect(App.lastGotoUrl).toMatch(/\#reply51$/)

  describe 'a.small_reply', ->
    describe 'when floor is 1, and login is 012345', ->
      beforeEach ->
        @htmlContainer.append """
          <div id="reply_body"></div>
          <a class="small_reply" data-floor="1" data-login="012345"></a>'
        """

      it 'replies to floor 1 and login 012345', ->
        spy = @spy(Topics, 'reply')
        Topics.init()
        @htmlContainer.find('a').click()
        console.log spy.args
        expect(spy.calledWith(1, '012345')).toBeTruthy()
