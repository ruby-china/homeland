这个是我对 Rails 默认模板的定制，模板乃是个人喜好，不一定适合你，仅供查考。此模板用于帮助我们快速生成管理后台得 CRUD 功能。 

## 需要得组件

* Rails 3.1
* [wice_grid](https://github.com/justinfrench/formtastic)
* [simple_form](https://github.com/plataformatec/simple_form)

## 安装

    $ cd ~/Downloads
    $ git clone git://github.com/huacnlee/rails_templates.git
    $ cp -R rails_templates/* ~/you_rails_project/lib/
    
## 使用用法

你可以根据自己得喜好修改模板，然后用 Rails scaffold generator 生成

    $ rails g scaffold Post title:string category_id:integer body:text
    $ rails g scaffold admin/posts title:string category_id:integer body:text
    $ rails g scaffold_controller admin/posts title:string category_id:integer body:text


Enjoy!

