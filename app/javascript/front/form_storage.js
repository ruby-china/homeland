window.FormStorage = {
  key(element) {
    return `${location.pathname} ${$(element).prop('id')}`;
  },

  init() {
    if (window.localStorage) {
      $(document).on('input', 'textarea[name*=body]', function () {
        const textarea = $(this);
        return localStorage.setItem(FormStorage.key(textarea), textarea.val());
      });

      $(document).on('submit', 'form', function () {
        const form = $(this);
        return form.find('textarea[name*=body]').each(function () {
          return localStorage.removeItem(FormStorage.key(this));
        });
      });

      return $(document).on('click', 'form a.reset', function () {
        const form = $(this).closest('form');
        return form.find('textarea[name*=body]').each(function () {
          return localStorage.removeItem(FormStorage.key(this));
        });
      });
    }
  },

  restore() {
    if (window.localStorage) {
      return $('textarea[name*=body]').each(function () {
        let value;
        const textarea = $(this);
        if (value = localStorage.getItem(FormStorage.key(textarea))) {
          return textarea.val(value);
        }
      });
    }
  }
};
