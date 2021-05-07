window.Editor = Backbone.View.extend({
  el: ".editor-toolbar",

  events: {
    "click #editor-upload-image": "browseUpload",
    "click .insert-codes a": "appendCodesFromHint",
    "click .pickup-emoji": "pickupEmoji",
  },

  initialize(opts) {
    this.initComponents();
    return this.initDropzone();
  },

  initDropzone() {
    let dropzone;
    const self = this;
    const editor = $("textarea.topic-editor");
    editor.wrap('<div class="topic-editor-dropzone"></div>');

    const editor_dropzone = $(".topic-editor-dropzone");
    editor_dropzone.on("paste", (event) => {
      return self.handlePaste(event);
    });

    return (dropzone = editor_dropzone.dropzone({
      url: "/photos",
      dictDefaultMessage: "",
      clickable: true,
      paramName: "file",
      maxFilesize: 20,
      uploadMultiple: false,
      acceptedFiles: "image/*",
      headers: {
        "X-CSRF-Token": $('meta[name="csrf-token"]').attr("content"),
      },
      previewContainer: false,
      processing() {
        $(".div-dropzone-alert").alert("close");
        return self.showUploading();
      },
      dragover() {
        editor.addClass("div-dropzone-focus");
      },
      dragleave() {
        editor.removeClass("div-dropzone-focus");
      },
      drop() {
        editor.removeClass("div-dropzone-focus");
        editor.focus();
      },
      success(header, res) {
        self.appendImageFromUpload(res.url);
      },
      error(temp, msg) {
        if (typeof msg === "string") {
          // from client side
          App.alert(msg);
        } else {
          // from server side
          App.alert(msg.message);
        }
      },
      totaluploadprogress(num) {},
      sending() {},
      queuecomplete() {
        self.restoreUploaderStatus();
      },
    }));
  },

  uploadFile(item, filename) {
    const self = this;
    const formData = new FormData();
    formData.append("file", item, filename);
    return $.ajax({
      url: "/photos",
      type: "POST",
      data: formData,
      dataType: "JSON",
      processData: false,
      contentType: false,
      beforeSend() {
        return self.showUploading();
      },
      success(e, status, res) {
        self.appendImageFromUpload(res.responseJSON.url);
        return self.restoreUploaderStatus();
      },
      error(res) {
        App.alert("上传失败");
        return self.restoreUploaderStatus();
      },
      complete() {
        return self.restoreUploaderStatus();
      },
    });
  },

  handlePaste(e) {
    const self = this;
    const pasteEvent = e.originalEvent;
    if (pasteEvent.clipboardData && pasteEvent.clipboardData.items) {
      const image = self.isImage(pasteEvent);
      if (image) {
        e.preventDefault();
        return self.uploadFile(image.getAsFile(), "image.png");
      }
    }
  },

  isImage(data) {
    let i = 0;
    while (i < data.clipboardData.items.length) {
      const item = data.clipboardData.items[i];
      if (item.type.indexOf("image") !== -1) {
        return item;
      }
      i++;
    }
    return false;
  },

  browseUpload(e) {
    $(".topic-editor").focus();
    $(".topic-editor-dropzone").click();
    return false;
  },

  showUploading() {
    const btn = $("#editor-upload-image");
    btn.addClass("active");
  },

  restoreUploaderStatus() {
    $("#editor-upload-image").removeClass("active");
  },

  appendImageFromUpload(src) {
    let src_merged = `![](${src})\n`;
    this.insertString(src_merged);
    return false;
  },

  // 往编辑器里面的光标前插入两个空白字符
  insertSpaces(e) {
    this.insertString("  ");
    return false;
  },

  // 往编辑器里面插入代码模版
  appendCodesFromHint(e) {
    const link = e.currentTarget;
    const language = link.getAttribute("data-lang");

    const txtBox = $(".topic-editor");
    const caret_pos = txtBox.caret("pos");
    let prefix_break = "";
    if (txtBox.val().length > 0) {
      prefix_break = "\n";
    }
    const src_merged = `${prefix_break}\`\`\`${language}\n\n\`\`\`\n`;
    const source = txtBox.val();
    const before_text = source.slice(0, caret_pos);
    txtBox.val(
      before_text + src_merged + source.slice(caret_pos + 1, source.count)
    );
    txtBox.caret("pos", caret_pos + src_merged.length - 5);
    txtBox.focus();
    txtBox.trigger("click");

    // click body to dismiss dropdown
    document.querySelector("body").click();
    return false;
  },

  insertString(str) {
    const $target = $(".topic-editor");
    const start = $target[0].selectionStart;
    const end = $target[0].selectionEnd;
    $target.val(
      $target.val().substring(0, start) + str + $target.val().substring(end)
    );
    $target[0].selectionStart = $target[0].selectionEnd = start + str.length;
    return $target.focus();
  },

  initComponents() {
    // 绑定文本框 tab 按键事件
    $("textarea.topic-editor").unbind("keydown.tab");
    $("textarea.topic-editor").bind("keydown.tab", "tab", (el) => {
      return this.insertSpaces(el);
    });

    return $("textarea.topic-editor").autogrow();
  },

  pickupEmoji() {
    if (!window._emojiModal) {
      window._emojiModal = new EmojiModalView();
    }
    window._emojiModal.show();
    return false;
  },
});
