import 'package:args/args.dart';

const String remote = "remote";
const String local = "local";
const String socketTimeOut = "socketTimeout";
const String connectTimeout = "connectTimeout";
const String outputFile = "outputFile";
const String outputFormat = "outputFormat";
const String concurrentRequests = "concurrentRequests";
const String showErrors = "showErrors";
const String serveRotatingProxy = "serveRotatingProxy";
const String rotateProxy = "rotateProxy";
const String host = "host";
const String port = "port";
const String updateTime = "updateTime";
const String timeToChangeProxy = "timeToChangeProxy";

final parser = ArgParser()
  ..addMultiOption(
    remote,
    abbr: 'r',
    splitCommas: true,
    help: "Urls to remote proxy list [url1,url2,...]",
  )
  ..addMultiOption(
    local,
    abbr: 'l',
    splitCommas: true,
    help: "Paths to proxy list [path1,path2,...]",
  )
  ..addOption(
    socketTimeOut,
    help: "Socket timeout [ms]",
    defaultsTo: "2000",
  )
  ..addOption(
    connectTimeout,
    help: "Connect timeout [ms]",
    defaultsTo: "5000",
  )
  ..addOption(
    outputFile,
    abbr: 'o',
    help: "Output file name",
    defaultsTo: "output",
  )
  ..addOption(
    outputFormat,
    abbr: 'f',
    help: "Output format: [json, csv]",
    defaultsTo: "csv",
  )
  ..addFlag(
    'help',
    abbr: 'h',
    help: 'Provide usage instruction',
    negatable: false,
  )
  ..addOption(
    concurrentRequests,
    abbr: 'c',
    help: "Concurrent requests [number]",
    defaultsTo: "100",
  )
  ..addFlag(
    showErrors,
    abbr: 'e',
    help: "Show errors",
    negatable: false,
    defaultsTo: false,
  )
  ..addFlag(
    serveRotatingProxy,
    abbr: 's',
    help: "Serve rotating proxy",
    negatable: false,
    defaultsTo: false,
  )
  ..addOption(
    rotateProxy,
    help: "Rotate proxy after n requests [number]",
  )
  ..addOption(
    host,
    help: "Rotating proxy server host",
    defaultsTo: "0.0.0.0",
  )
  ..addOption(
    port,
    help: "Rotating proxy server port",
    defaultsTo: "8080",
  )
  ..addOption(
    updateTime,
    help: "Update proxy list every n seconds (rotation server only)",
    abbr: 'u',
  )
  ..addOption(
    timeToChangeProxy,
    help: "Time to change proxy (rotation server only)",
    abbr: 't',
  );
