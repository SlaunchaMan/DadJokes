# DadJokes

DadJokes is a command-line utility for macOS to retrieve dad jokes from
[https://icanhazdadjoke.com](https://icanhazdadjoke.com). To get a dad joke, run
the executable:

```
$ dadjokes
How was the snow globe feeling after the storm? A little shaken.
```

The easiest way to get the binary from the source is to just use Swift; the
`swift run` command will build and run automatically:

```
$ swift run
Two peanuts were walking down the street. One was a salted.
```

### Command-Line Arguments

Feeling impatient? The `-t` argument (or `--timeout`) allows you to specify a
timeout in seconds:

```
$ dadjokes -t 2
How can you tell a vampire has a cold? They start coffin.
```

If you want to change the URL that DadJokes uses to your own super-secret stash
of dad jokes, use the `-u` (or `--url`) command:

```
$ dadjokes -u "https://example.com"
This is a super-secret dad joke!
```

### Development

DadJokes is written in Swift using Apple’s [ArgumentParser][1] library for
parsing command-line arguments and [Alamofire][2] for networking. For testing,
it uses XCTest, [OHHTTPStubs][2], and [GCDWebServer][3].

[1]: https://github.com/apple/swift-argument-parser
[2]: https://github.com/Alamofire/Alamofire
[3]: https://github.com/AliSoftware/OHHTTPStubs
[4]: https://github.com/swisspol/GCDWebServer
