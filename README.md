# Alijigock

Alijigock is a employee management bot for Slack. (It's joke bot)

## Installation

```
$ gem install alijigock
```

## Start

```
$ alijigock --dotenv
```

and access `http://localhost:5000` and invite your bot in channel!

## env

- CLIENT_ID
    - Slack App Client ID
- CLIENT_SECRET
    - Slack App Client Secret
- SLACK_TOKEN
    - Slack bot integration token ( https://api.slack.com/bot-users )
- PORT
    - Setting page's port
    - default: `5000`
- STORE
    - `file` or `redis`
    - default: `file`
- REDIS_URL
    - only `STORE='redis'`
    - ex) `redis://localhost:6379`

You can write to `.env`

```
CLIENT_ID='xxx.xxx'
CLIENT_SECRET='xxxxxxxxxx'
SLACK_TOKEN='xxxx-xxxxxxx-xxxxxxxx'
PORT='8080'
STORE='redis'
REDIS_URL='redis://my-redis-server:6379'
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rutan/alijigock.

## License
MIT
