describe 'App', ->
  describe 'scanLogins', ->
    describe 'when there is an author bob(012345), and replier jack(054321)', ->
      beforeEach ->
        @htmlContainer.append """
          <div id="topic-show">
            <div class="leader">
              <a data-author="true" data-name="012345">bob</a>
            </div>
          </div>
          <div id="replies">
            <span class="name"><a data-name="054321">jack</a></span>
          </div>
        """
        @logins = App.scanLogins(@htmlContainer.find('a'))
        @logins = ({login: k, name: v} for k, v of @logins)

      it 'has 2 logins', ->
        expect(@logins.length).toBe 2
      it 'has the author with name 012345', ->
        expect(@logins[0].name).toEqual '012345'
      it 'has the author with login bob', ->
        expect(@logins[0].login).toEqual 'bob'
      it 'has the replier with name 054321', ->
        expect(@logins[1].name).toEqual '054321'
      it 'has the author with login jack', ->
        expect(@logins[1].login).toEqual 'jack'
