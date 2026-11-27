import 'package:flutter/material.dart';
import 'package:folio/screens/read_device/read_device_controller.dart';
import 'package:folio/screens/read_device/widgets/scan_error_view.dart';
import 'package:folio/screens/read_device/widgets/scan_folder_list.dart';
import 'package:folio/screens/read_device/widgets/scan_header.dart';
import 'package:folio/screens/read_device/widgets/scan_progress.dart';
import 'package:folio/widgets/primary_button.dart';

// EXPLICA: esta tela só MONTA as peças. Cada pedaço visual está num widget
// pequeno em `widgets/`, e os dados vêm do controller. Se quiser mudar o
// visual de algo, vá no widget dele, não aqui.
//
// É StatefulWidget porque precisa criar e destruir o controller junto com a
// tela (initState/dispose). Um StatelessWidget não tem dispose.
class ReadDeviceScreen extends StatefulWidget {
  const ReadDeviceScreen({super.key});

  @override
  State<ReadDeviceScreen> createState() => _ReadDeviceScreenState();
}

class _ReadDeviceScreenState extends State<ReadDeviceScreen> {
  // EXPLICA: criado uma única vez, como campo. Se fosse criado dentro do
  // build, a leitura recomeçaria do zero a cada redesenho da tela.
  final _controller = ReadDeviceController();

  @override
  void dispose() {
    // EXPLICA: libera o controller (e cancela a leitura) ao sair da tela.
    _controller.dispose();
    super.dispose();
  }

  void _goBack() => Navigator.of(context).maybePop();

  void _openFolders() {
    // TODO: pushReplacement(FadeRoute(PastasScreen()))
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // EXPLICA: SafeArea evita que o conteúdo fique embaixo da barra de
      // status e da barra de navegação do Android.
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          // EXPLICA: ListenableBuilder reconstrói só este trecho quando o
          // controller chama notifyListeners(). O resto da tela não é
          // redesenhado à toa.
          child: ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              // EXPLICA: dois "modos" da tela: erro ou conteúdo normal.
              if (_controller.hasFailed) return ScanErrorView(onBack: _goBack);
              return _buildContent();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final state = _controller.state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        ScanHeader(state: state), // título, total e subtítulo
        const SizedBox(height: 20),
        ScanProgress(state: state), // barra e porcentagem
        const SizedBox(height: 20),
        // EXPLICA: Expanded faz o card da lista ocupar TODO o espaço livre
        // entre a barra e o botão. É isso que empurra o botão para o rodapé
        // e dá altura limitada para a lista poder rolar.
        Expanded(child: ScanFolderList(state: state)),
        const SizedBox(height: 20),
        PrimaryButton(
          label: _controller.isDone ? 'Ver pastas encontradas' : 'Lendo…',
          // EXPLICA: `onPressed: null` desabilita o botão (e ele fica
          // esmaecido). Só habilita quando a leitura termina.
          onPressed: _controller.isDone ? _openFolders : null,
        ),
      ],
    );
  }
}
