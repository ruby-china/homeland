# Guide

This document showup for how to correctly use **Markdown** typesetting. It is necessary to learn this to make your article better and clearer typesetting.

> QUOTE: Markdown is a text formatting syntax inspired

## Grammar guide

### Normal contents

This content shows some small formats in the content, such as:

- **Bold** - `**Bold**`
- _Italic_ - `*Italic*`
- ~~Strikethrough~~ - `~~Strikethrough~~`
- `Code` - `\`Code\``
- [Link](http://github.com) - `[Link](http://github.com)`
- [username@gmail.com](mailto:username@gmail.com) - `[username@gmail.com](mailto:username@gmail.com)`

### Mention

@foo @bar @someone ... Use `@` for mention users in topics and replies. After the information is submitted, the mentioned users will be notified by the system. In order to let him follow this topic or reply.

### Emoji

Support emoji, you can use the system default Emoji symbol.

You can also use the emoticon in the picture, input `:` and a smart reminder will appear.

#### Emoji example

:smile: :laughing: :dizzy_face: :sob: :cold_sweat: :sweat_smile: :cry: :triumph: :heart_eyes: :relaxed: :sunglasses: :weary:

:+1: :-1: :100: :clap: :bell: :gift: :question: :bomb: :heart: :coffee: :cyclone: :bow: :kiss: :pray: :sweat_drops: :hankey: :exclamation: :anger:

### Heading - Heading 3

You can choose to use H2 to H6, use ##(N) to start, H1 cannot be used, it will be automatically converted to H2.

> NOTE: Don’t forget that # needs a space after it!

#### Heading 4

##### Heading 5

###### Heading 6

### Image

```
![alt](http://image-path.png)
![alt](http://image-path.png "Image Title")
![Image with size](http://image-path.png =300x200)
![Image with width and auto height](http://image-path.png =300x)
![Image with height and auto width](http://image-path.png =x200)
```

### Code Block

#### Normal

```
*emphasize*    **strong**
_emphasize_    __strong__
@a = 1
```

#### Code Highlight

If the language name is added after \`\`\`, it can have the effect of syntax highlighting, such as:

##### Demo Ruby code highlighting

```ruby
class PostController < ApplicationController
  def index
    @posts = Post.last_actived.limit(10)
  end
end
```

### Ordered, unordered list

#### Unordered List

- Ruby
  - Rails
    - ActiveRecord
- Go
  - Gofmt
  - Revel
- Node.js
  - Koa
  - Express

#### Ordered List

1. Node.js
1. Express
1. Koa
1. Sails
1. Ruby
1. Rails
1. Sinatra
1. Go

### Table

If you need to display data or something, you can choose to use a table:

| header 1 | header 3 |
| -------- | -------- |
| cell 1   | cell 2   |
| cell 3   | cell 4   |
| cell 5   | cell 6   |

### Paragraph

Line breaks with blanks will be automatically converted into a paragraph with a certain paragraph spacing for easy reading.

Please note that the line breaks of the Markdown source code are left blank.

### Video

We support Youtube, Vimeo, Youku, BiliBili video insertion, you only need to copy the video playback page, the URL address of the web page in the browser address bar, and paste it into the topic/reply text box. After submission, it will be automatically converted into a video player.

#### For example

**Youtube**

https://www.youtube.com/watch?v=52AMJwF7P0w

**Vimeo**

https://vimeo.com/460511888

**Youku**

https://v.youku.com/v_show/id_XNDU4Mzg4Mjc2OA==.html

**BiliBili**

https://www.bilibili.com/video/BV1uv411B7MK

···
