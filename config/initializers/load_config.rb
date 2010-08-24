# 配置文件载入
APP_CONFIG = YAML.load_file("#{Rails.root}/config/config.yml")[Rails.env]
