import 'package:args/args.dart';
import 'package:wake_on_lan/wake_on_lan.dart';

Future<void> wake(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false)
    ..addOption('host')
    ..addOption('mac')
    ..addOption('repeat');
  final result = parser.parse(arguments);
  if (result['help'] != null) {
    print(parser.usage);
    return;
  }

  final rHost = result['host'] as String?,
      rMac = result['mac'] as String?,
      rRepeat = result['repeat'] as int? ?? 3;
  if (rHost == null || rHost.isEmpty) {
    throw ArgumentError.notNull('host');
  }
  if (rMac == null || rMac.isEmpty) {
    throw ArgumentError.notNull('mac');
  }
  if (MACAddress.validate(rMac)) {
    throw ArgumentError('invalid MAC address');
  }
  final uri = Uri.parse(rHost);
  if (uri.host.isEmpty) {
    throw ArgumentError('invalid host');
  }
  final host = uri.host;
  final IPv4Address ipv4;
  if (IPv4Address.validate(host)) {
    ipv4 = IPv4Address(host);
  } else {
    ipv4 = await IPv4Address.fromHost(host);
  }
  final mac = MACAddress(rMac);
  final int port;
  if (uri.port == 0) {
    port = 9;
  } else {
    port = uri.port;
  }

  final wol = WakeOnLAN(ipv4, mac, port: port);
  await wol.wake(repeat: rRepeat);
}
