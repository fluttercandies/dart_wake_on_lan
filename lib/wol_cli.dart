import 'package:args/args.dart';
import 'package:wake_on_lan/wake_on_lan.dart';

Future<void> wake(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false)
    ..addOption('host')
    ..addOption('port', defaultsTo: '9')
    ..addOption('mac')
    ..addOption('repeat', defaultsTo: '3');
  final result = parser.parse(arguments);
  if (result['help'] == true) {
    print(parser.usage);
    return;
  }

  String? rHost = result['host'] as String?;
  final rMac = result['mac'] as String?,
      rPort = int.parse(result['port']),
      rRepeat = int.parse(result['repeat']);
  if (rHost == null || rHost.isEmpty) {
    throw ArgumentError.notNull('host');
  }
  if (rMac == null || rMac.isEmpty) {
    throw ArgumentError.notNull('mac');
  }
  if (!MACAddress.validate(rMac, delimiter: ':').state &&
      !MACAddress.validate(rMac, delimiter: '-').state) {
    throw ArgumentError('invalid MAC address');
  }
  if (!rHost.startsWith(RegExp(r'https?://'))) {
    rHost = 'http://$rHost';
  }
  final uri = Uri.parse(rHost);
  if (uri.host.isEmpty) {
    throw ArgumentError('invalid host');
  }
  final host = uri.host;
  final IPAddress ipv4;
  if (IPAddress.validate(host).state) {
    ipv4 = IPAddress(host);
  } else {
    ipv4 = await IPAddress.fromHost(host);
  }
  MACAddress mac;
  try {
    mac = MACAddress(rMac, delimiter: ':');
  } catch (_) {
    mac = MACAddress(rMac, delimiter: '-');
  }

  final wol = WakeOnLAN(ipv4, mac, port: rPort);
  await wol.wake(repeat: rRepeat);
}
