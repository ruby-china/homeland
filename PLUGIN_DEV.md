如何编写 Homeland 的插件
----------------------

Homeland 的插件，基于 [Rails Engine](http://guides.rubyonrails.org/engines.html)。

## Get started

新建一个 Rails Engine:

你可以使用 `rails plugin new homeland-<plugin-name> --mountable` 的方式来创建一个插件。

```bash
rails plugin new homeland-foo --mountable
```

将会生成 Plugin 的项目目录。

## 注册 Homeland Plugin

打开 lib/homeland/foo/engine.rb

```rb
module Homeland
  module Foo
    # 关于 Engine 的细节，可以阅读 Rails Guides - Engines 部分的内容
    # http://guides.rubyonrails.org/engines.html
    class Engine < ::Rails::Engine
      isolate_namespace Homeland::Foo

      initializer 'homeland.foo.init' do |app|
        # 确定应用 config.modules 启用了 foo，才开启
        return unless Setting.has_module?(:foo)
        # 注册 Homeland Plugin
        Homeland.register_plugin do |plugin|
          # 插件名称，应用 Ruby 的变量命名风格，例如 foo_bar
          plugin.name = 'foo'
          # 插件的名称用于显示
          plugin.display_name = '测试插件'
          # 版本号
          plugin.version = Homeland::Foo::VERSION
          plugin.description = '..'
          # 是否在主导航栏显示链接
          plugin.navbar_link = true
          # 是否在用户菜单显示链接
          plugin.user_menu_link = true
          # 是否在管理界面的导航显示链接，需要额外配置 plugin.admin_path
          plugin.admin_navbar_link = true
          # 应用的根路径，用于生成链接
          plugin.root_path = "/foos"
          # 应用的管理后台路径
          plugin.admin_path = "/admin/foos"
        end

        app.routes.prepend do
          mount Homeland::Foo::Engine => '/'
        end

        # 让 Homeland Migration 的时候，包含插件的 Migration
        app.config.paths["db/migrate"].concat(config.paths["db/migrate"].expanded)
      end
    end
  end
end
```

## 如何测试 Plugin

你需要准备好 Homeland 源代码的开发环境，并将自己的插件加入到 Homeland 项目的 Gemfile 里面：

例如

```
# Homeland 主项目源代码
~/work/homeland
# 插件源代码
~/work/homeland-foo
```

修改 homeland/Gemfile

```rb
# 引用上层路径的 Plugin 目录
gem 'homeland-foo', path: '../homeland-foo'
```

然后启动 Homeland，打开相应的插件目录验证。

暂时没有自动化测试的方案。

## 参考实现

https://github.com/ruby-china/homeland-press
