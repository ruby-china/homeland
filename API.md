# API 文档

## OAuth 2 / API 认证

在使用 API 之前，你需要 [注册应用](/oauth/applications/new) 并获得可以 **OAuth App** 信息。并使用标准的 OAuth 2 实现登录，获得 `access_token` 信息。

### OAuth 路径

- /oauth/authorize
- /oauth/token
- /oauth/revoke

### Response 说明

所有 Response 采用 JSON 格式返回，请求状态通过 HTTP Status 返回。

### HTTP Status

错误的情况 Response Body 一定会是这样的格式: `{ "error" : "Error message" }`

- 200, 201 - 请求成功，或执行成功。
- 400 - 参数不符合 API 的要求、或者数据格式验证没有通过，请配合 Response Body 里面的 error 信息确定问题。
- 401 - 用户认证失败，或缺少认证信息，比如 access_token 过期，或没传，可以尝试用 refresh_token 方式获得新的 access_token。
- 403 - 当前用户对资源没有操作权限。
- 404 - 资源不存在。
- 500 - 服务器异常。

#### 资源权限描述

在部分 API 的 response 内容里面你会看到 `abilities` 节点，这是特别标识当前 `access_token` 对应的用户对此资源的权限。

请参考源代码，确定那些路径是需要用户认证的，需要用户认证的路径，你需要带上 `access_token=?` 参数。

**例如**

```json
{
  "topic": {
    "id": 256170,
    ....,
    "abilities": { "update": true, "destroy": true }
  }
}
```

- update 是否有权限修改
- destroy 是否有权限删除

## API 路由

API 的详细文档，请访问 [Api::V3](/api-doc/Api/V3.html) 阅读。

## 演示

我们用 Ruby 演示一下访问 [/api/v3/hello.json](/api-doc/Api/V3/RootController.html#hello-instance_method) 这个路径，其中包含 OAuth 2 的流程。

_这里用到 RubyGem [oauth2](https://github.com/intridea/oauth2)_

```rb
require "oauth2"
client = OAuth2::Client.new('client id', 'secret', site: 'https://ruby-china.org')
access_token = client.password.get_token('username', 'password')
res = Faraday.get("https://ruby-china.org/api/v3/hello.json?access_token=#{access_token.token}")
puts res.status
puts res.body
```

最后输出

```rb
{ 'current_user' : 'username' }
```